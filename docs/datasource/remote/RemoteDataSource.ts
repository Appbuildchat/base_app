/**
 * 원격 데이터 소스 클래스
 * API 요청과 응답을 처리하는 클래스입니다.
 */

import axios, { AxiosError, AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { serverUrl } from '../../../config/server/server.ts';
import { secureDataSource } from '../index.ts';
import { ApiResponse } from '../../type/responseType.ts';

export class RemoteDataSource {
  private axiosInstance: AxiosInstance;
  private refreshingToken: boolean = false;
  private refreshQueue: Array<() => void> = [];

  constructor() {
    this.axiosInstance = axios.create({
      baseURL: serverUrl,
      timeout: 30000, // Android 업로드를 위해 30초로 증가
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // 요청 인터셉터 설정
    this.axiosInstance.interceptors.request.use(
      async (config) => {
        // 디버깅: requiresAuth 값 확인
        console.log('[Interceptor] URL:', config.url);
        console.log('[Interceptor] requiresAuth:', config.headers?.requiresAuth);

        // 인증이 필요한 요청에 토큰 추가
        if (config.headers?.requiresAuth !== false) {
          const token = await secureDataSource.getAccessToken();
          console.log('[Interceptor] Adding token:', token ? 'YES' : 'NO');
          if (token) {
            config.headers.Authorization = `Bearer ${token}`;
          }
        } else {
          console.log('[Interceptor] Skipping auth for this request');
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // 응답 인터셉터 설정
    this.axiosInstance.interceptors.response.use(
      (response) => {
        return response;
      },
      async (error: AxiosError) => {
        const originalRequest = error.config as AxiosRequestConfig & { _retry?: boolean };

        if (error.response?.status === 401 && !originalRequest._retry) {
          if (this.refreshingToken) {
            // 이미 토큰 갱신 중이면 대기열에 추가
            return new Promise(resolve => {
              this.refreshQueue.push(() => {
                originalRequest._retry = true;
                resolve(this.axiosInstance(originalRequest));
              });
            });
          }

          this.refreshingToken = true;
          originalRequest._retry = true;

          try {
            // 토큰 갱신 시도
            const refreshToken = await secureDataSource.getRefreshToken();
            if (!refreshToken) {
              // 로그아웃 처리 필요
              secureDataSource.clearTokens();
              return Promise.reject(error);
            }

            const response = await this.refreshTokenCall({ refreshToken });

            if (response.status === 200 && response.data?.data) {
              // 새로운 토큰 저장
              await secureDataSource.setAccessToken(response.data.data.accessToken);
              if (response.data.data.refreshToken) {
                await secureDataSource.setRefreshToken(response.data.data.refreshToken);
              }

              // 대기열에 있는 요청 처리
              this.refreshQueue.forEach(callback => callback());
              this.refreshQueue = [];

              // 원래 요청 재시도
              return this.axiosInstance(originalRequest);
            } else {
              // 토큰 갱신 실패 로그아웃 처리
              secureDataSource.clearTokens();
              return Promise.reject(error);
            }
          } catch (refreshError) {
            secureDataSource.clearTokens();
            return Promise.reject(refreshError);
          } finally {
            this.refreshingToken = false;
          }
        }

        return Promise.reject(error);
      }
    );
  }

  /**
   * GET 요청 메서드
   * @param endpoint API 엔드포인트
   * @param params 요청 파라미터
   * @param requiresAuth 인증 필요 여부
   */
  async get<T>(endpoint: string, params?: any, requiresAuth: boolean = true): Promise<ApiResponse<T>> {
    try {
      const response = await this.axiosInstance.get<ApiResponse<T>>(endpoint, {
        params,
        headers: { requiresAuth },
      });
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * POST 요청 메서드
   * @param endpoint API 엔드포인트
   * @param data 요청 데이터
   * @param requiresAuth 인증 필요 여부
   */
  async post<T>(endpoint: string, data?: any, requiresAuth: boolean = true): Promise<ApiResponse<T>> {
    try {
      const response = await this.axiosInstance.post<ApiResponse<T>>(endpoint, data, {
        headers: { requiresAuth },
      });
      return response.data;
      console.log()
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * POST 요청 메서드 (multipart/form-data 지원)
   * @param endpoint API 엔드포인트
   * @param data 요청 데이터 (FormData)
   * @param options 추가 옵션 (headers 등)
   */
  async postFormData<T>(endpoint: string, data: FormData, options?: { requiresAuth?: boolean }): Promise<ApiResponse<T>> {
    try {
      const headers: any = {
        // Content-Type을 명시적으로 multipart/form-data로 설정하지 않음
        // React Native와 브라우저가 자동으로 boundary와 함께 설정하도록 함
        'Content-Type': undefined,
      };

      // requiresAuth 옵션 처리
      if (options?.requiresAuth !== undefined) {
        headers.requiresAuth = options.requiresAuth;
      }

      const response = await this.axiosInstance.post<ApiResponse<T>>(endpoint, data, {
        headers,
      });

      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * PUT 요청 메서드
   * @param endpoint API 엔드포인트
   * @param data 요청 데이터
   * @param requiresAuth 인증 필요 여부
   */
  async put<T>(endpoint: string, data?: any, requiresAuth: boolean = true): Promise<ApiResponse<T>> {
    try {
      const response = await this.axiosInstance.put<ApiResponse<T>>(endpoint, data, {
        headers: { requiresAuth },
      });
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * DELETE 요청 메서드
   * @param endpoint API 엔드포인트
   * @param params 요청 파라미터
   * @param requiresAuth 인증 필요 여부
   */
  async delete<T>(endpoint: string, params?: any, requiresAuth: boolean = true): Promise<ApiResponse<T>> {
    try {
      const response = await this.axiosInstance.delete<ApiResponse<T>>(endpoint, {
        params,
        headers: { requiresAuth },
      });
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * PATCH 요청 메서드
   * @param endpoint API 엔드포인트
   * @param data 요청 데이터
   * @param requiresAuth 인증 필요 여부
   */
  async patch<T>(endpoint: string, data?: any, requiresAuth: boolean = true): Promise<ApiResponse<T>> {
    try {
      const response = await this.axiosInstance.patch<ApiResponse<T>>(endpoint, data, {
        headers: { requiresAuth },
      });
      return response.data;
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * 리프레시 토큰으로 새로운 액세스 토큰을 요청합니다
   * @param refreshToken 리프레시 토큰
   */
  async refreshTokenCall({ refreshToken }: { refreshToken: string }): Promise<AxiosResponse<ApiResponse>> {
    try {
      const response = await this.axiosInstance.post('/auth/refresh', {
        refreshToken,
      }, {
        headers: {
          requiresAuth: false, // 토큰 갱신 요청은 인증 불필요
        },
      });
      return response;
    } catch (error) {
      console.log('[RemoteDataSource] 토큰 갱신 실패:', error);
      throw error;
    }
  }

  // === FCM 관련 API 호출 메서드들 ===

  /**
   * FCM 토큰을 서버에 등록합니다
   * @param token FCM 토큰
   */
  async registerFcmToken(token: string): Promise<ApiResponse> {
    try {
      const response = await this.post(`fcm?fcmToken=${token}`, {}, true);
      console.log('[RemoteDataSource] FCM 토큰 등록 성공:', token);
      return response;
    } catch (error) {
      console.log('[RemoteDataSource] FCM 토큰 등록 실패:', error);
      throw error;
    }
  }

  /**
   * FCM 토큰을 서버에서 업데이트합니다
   * @param token 새로운 FCM 토큰
   */
  async updateFcmToken(token: string): Promise<ApiResponse> {
    try {
      const response = await this.post(`fcm?fcmToken=${token}`, {}, true);
      console.log('[RemoteDataSource] FCM 토큰 업데이트 성공:', token);
      return response;
    } catch (error) {
      console.log('[RemoteDataSource] FCM 토큰 업데이트 실패:', error);
      throw error;
    }
  }

  /**
   * FCM 토큰을 서버에서 해제합니다
   * TODO: 서버에 해당 엔드포인트가 구현되면 주석 해제
   */
  /*
  async unregisterFcmToken(): Promise<ApiResponse> {
    try {
      const response = await this.axiosInstance.delete('/notifications/unregister');
      console.log('[RemoteDataSource] FCM 토큰 해제 성공');
      return response.data;
    } catch (error) {
      this.logError('FCM 토큰 해제 실패', error);
      throw error;
    }
  }
  */

  /**
   * 알림 설정을 서버에 동기화합니다
   * @param settings 알림 설정 객체
   * TODO: 서버에 해당 엔드포인트가 구현되면 주석 해제
   */
  /*
  async syncNotificationSettings(settings: {
    pushNotificationEnabled: boolean;
    chatNotificationEnabled: boolean;
    orderNotificationEnabled: boolean;
    marketingNotificationEnabled: boolean;
  }): Promise<ApiResponse> {
    try {
      const response = await this.axiosInstance.put('/notifications/settings', settings);
      console.log('[RemoteDataSource] 알림 설정 동기화 성공:', settings);
      return response.data;
    } catch (error) {
      this.logError('알림 설정 동기화 실패', error);
      throw error;
    }
  }
  */

  /**
   * 서버에서 알림 설정을 가져옵니다
   * TODO: 서버에 해당 엔드포인트가 구현되면 주석 해제
   */
  /*
  async getNotificationSettings(): Promise<ApiResponse> {
    try {
      const response = await this.axiosInstance.get('/notifications/settings');
      console.log('[RemoteDataSource] 알림 설정 조회 성공');
      return response.data;
    } catch (error) {
      this.logError('알림 설정 조회 실패', error);
      throw error;
    }
  }
  */

  /**
   * 네트워크 상태 확인 메서드
   * @returns 네트워크 상태 확인 결과
   */
  async checkNetworkStatus(): Promise<boolean> {
    try {
      const response = await this.axiosInstance.get('https://3.34.60.216.nip.io/user/status?userId=daorder', {
        headers: { requiresAuth: false },
        timeout: 5000, // 5초 타임아웃
      });
      return response.status === 200;
    } catch (error) {
      console.log('[Network Check Error]', error);
      return false;
    }
  }

  /**
   * 에러 처리 메서드
   * @param error Axios 에러
   */
  private handleError(error: any): ApiResponse<any> {
    console.log('[API Error]1', error);
    console.log('[API Error]2', error.data);
    console.log('[API Error]3', error.response?.data);
    console.log('[API Error]4', error.response);

    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError<ApiResponse<any>>;

      if (axiosError.response) {
        // 서버 응답이 있는 경우
        return axiosError.response.data || {
          status: axiosError.response.status,
          message: axiosError.response.statusText,
          data: null
        };
      }
    }

    // 기본 에러 응답
    return {
      status: 500,
      message: '네트워크 오류가 발생했습니다.',
      data: null
    };
  }
}
