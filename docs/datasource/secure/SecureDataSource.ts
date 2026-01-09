/**
 * 보안 데이터 소스 클래스
 * 민감한 데이터(토큰 등)를 안전하게 저장하기 위한 클래스입니다.
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import axios, { AxiosError } from 'axios';
import { requestPermission, getToken, onTokenRefresh, getMessaging, AuthorizationStatus } from '@react-native-firebase/messaging';

// 보안 저장소 키
const SECURE_KEYS = {
  ACCESS_TOKEN: 'access_token',
  REFRESH_TOKEN: 'refresh_token',
  FCM_TOKEN: 'fcm_token',
  NOTIFICATION_ENABLED: 'notification_enabled',
};

// API 주소
const API_BASE_URL = 'http://3.34.60.216:8080';

// Axios 인스턴스 생성 (타임아웃 및 기본 설정)
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000, // 30초 타임아웃
  headers: {
    'Content-Type': 'application/json',
  },
});

export class SecureDataSource {
  /**
   * 네트워크 연결 상태 확인
   */

  /**
   * 에러 로깅 및 분석
   */
  private logError(context: string, error: any): void {
    console.log(`[SecureDataSource] ${context}:`, {
      message: error.message,
      code: error.code,
      response: error.response?.data,
      status: error.response?.status,
      isAxiosError: axios.isAxiosError(error),
      isNetworkError: error.code === 'NETWORK_ERROR' || error.message === 'Network Error',
    });
  }

  /**
   * 보안 데이터 저장
   * @param key 저장 키
   * @param value 저장할 데이터
   */
  async setSecureItem(key: string, value: string): Promise<void> {
    try {
      await AsyncStorage.setItem(key, value);
      console.log(`[SecureDataSource] 보안 데이터 저장 성공: ${key}`);
    } catch (error) {
      console.log(`[SecureDataSource] 보안 데이터 저장 실패: ${key}`, error);
      throw error;
    }
  }

  /**
   * 보안 데이터 조회
   * @param key 조회할 키
   */
  async getSecureItem(key: string): Promise<string | null> {
    try {
      return await AsyncStorage.getItem(key);
    } catch (error) {
      console.log(`[SecureDataSource] 보안 데이터 조회 실패: ${key}`, error);
      return null;
    }
  }

  /**
   * 보안 데이터 삭제
   * @param key 삭제할 키
   */
  async removeSecureItem(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
      console.log(`[SecureDataSource] 보안 데이터 삭제 성공: ${key}`);
    } catch (error) {
      console.log(`[SecureDataSource] 보안 데이터 삭제 실패: ${key}`, error);
      throw error;
    }
  }

  /**
   * 액세스 토큰 저장
   * @param token 액세스 토큰
   */
  async setAccessToken(token: string): Promise<void> {
    return this.setSecureItem(SECURE_KEYS.ACCESS_TOKEN, token);
  }

  /**
   * 액세스 토큰 조회
   */
  async getAccessToken(): Promise<string | null> {
    return this.getSecureItem(SECURE_KEYS.ACCESS_TOKEN);
  }

  /**
   * 리프레시 토큰 저장
   * @param token 리프레시 토큰
   */
  async setRefreshToken(token: string): Promise<void> {
    return this.setSecureItem(SECURE_KEYS.REFRESH_TOKEN, token);
  }

  /**
   * 리프레시 토큰 조회
   */
  async getRefreshToken(): Promise<string | null> {
    return this.getSecureItem(SECURE_KEYS.REFRESH_TOKEN);
  }

  /**
   * 모든 토큰 삭제
   */
  async clearTokens(): Promise<void> {
    try {
      await Promise.all([
        this.removeSecureItem(SECURE_KEYS.ACCESS_TOKEN),
        this.removeSecureItem(SECURE_KEYS.REFRESH_TOKEN),
      ]);
      console.log('[SecureDataSource] 모든 토큰 삭제 완료');
    } catch (error) {
      this.logError('토큰 삭제 실패', error);
      throw error;
    }
  }

  // === FCM 관련 메서드들 ===

  /**
   * FCM 토큰을 가져와서 저장합니다
   */
  async getFcmToken(): Promise<string | null> {
    try {
      const messagingInstance = getMessaging();
      const authStatus = await requestPermission(messagingInstance);
      const enabled =
        authStatus === AuthorizationStatus.AUTHORIZED ||
        authStatus === AuthorizationStatus.PROVISIONAL;

      if (!enabled) {
        console.log('[SecureDataSource] FCM 권한이 거부되었습니다.');
        return null;
      }

      const token = await getToken(messagingInstance);
      if (token) {
        await this.setSecureItem(SECURE_KEYS.FCM_TOKEN, token);
        console.log('[SecureDataSource] FCM 토큰 저장됨:', token);
        return token;
      }
      return null;
    } catch (error) {
      this.logError('FCM 토큰 가져오기 실패', error);
      return null;
    }
  }

  /**
   * 저장된 FCM 토큰을 가져옵니다
   */
  async getStoredFcmToken(): Promise<string | null> {
    return this.getSecureItem(SECURE_KEYS.FCM_TOKEN);
  }

  /**
   * FCM 토큰을 저장합니다
   */
  async setFcmToken(token: string): Promise<void> {
    return this.setSecureItem(SECURE_KEYS.FCM_TOKEN, token);
  }

  /**
   * 알림 활성화 상태를 설정합니다
   */
  async setNotificationEnabled(enabled: boolean): Promise<void> {
    try {
      await this.setSecureItem(SECURE_KEYS.NOTIFICATION_ENABLED, JSON.stringify(enabled));
      console.log('[SecureDataSource] 알림 설정 저장됨:', enabled);
    } catch (error) {
      this.logError('알림 설정 저장 실패', error);
      throw error;
    }
  }

  /**
   * 알림 활성화 상태를 가져옵니다
   */
  async isNotificationEnabled(): Promise<boolean> {
    try {
      const enabled = await this.getSecureItem(SECURE_KEYS.NOTIFICATION_ENABLED);
      return enabled ? JSON.parse(enabled) : true; // 기본값은 true
    } catch (error) {
      this.logError('알림 설정 가져오기 실패', error);
      return true;
    }
  }

  /**
   * FCM 토큰 새로고침 리스너 등록
   */
  onTokenRefresh(callback: (token: string) => void) {
    const messagingInstance = getMessaging();
    return onTokenRefresh(messagingInstance, async (token) => {
      console.log('[SecureDataSource] FCM 토큰 새로고침됨:', token);
      await this.setFcmToken(token);
      callback(token);
    });
  }

  /**
   * FCM 권한 요청
   */
  async requestNotificationPermission(): Promise<boolean> {
    try {
      const messagingInstance = getMessaging();
      const authStatus = await requestPermission(messagingInstance);
      const enabled =
        authStatus === AuthorizationStatus.AUTHORIZED ||
        authStatus === AuthorizationStatus.PROVISIONAL;
      
      console.log('[SecureDataSource] FCM 권한 상태:', authStatus, '활성화:', enabled);
      return enabled;
    } catch (error) {
      this.logError('FCM 권한 요청 실패', error);
      return false;
    }
  }

  /**
   * 토큰 존재 여부 확인 (로그인 상태 확인용)
   */
  async hasTokens(): Promise<boolean> {
    const accessToken = await this.getAccessToken();
    const refreshToken = await this.getRefreshToken();
    return !!accessToken && !!refreshToken;
  }

  /**
   * 액세스 토큰 유효성 확인
   * @returns 토큰이 유효하면 true, 아니면 false
   * @description 토큰이 있고, 유효한지 확인합니다. 서버에 검증 요청을 보냅니다.
   */
  async isTokenValid(): Promise<boolean> {
    try {
      const accessToken = await this.getAccessToken();

      if (!accessToken) {
        console.log('[SecureDataSource] 토큰이 존재하지 않습니다.');
        return false;
      }

      await apiClient.get('/user/profile', {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      });

      // 응답이 성공적이면 토큰이 유효한 것으로 판단
      return true;
    } catch (error) {
      this.logError('토큰 유효성 확인 실패', error);
      return false;
    }
  }

  /**
   * 토큰 재발급
   * @returns 토큰 재발급 성공 여부
   * @description 리프레시 토큰을 사용하여 액세스 토큰을 재발급받습니다.
   */
  async refreshTokens(): Promise<boolean> {
    try {
      const refreshToken = await this.getRefreshToken();

      if (!refreshToken) {
        console.log('[SecureDataSource] 리프레시 토큰이 존재하지 않습니다.');
        return false;
      }


      console.log('[SecureDataSource] 토큰 갱신 시도 중...');

      // Swagger 문서 기반 토큰 갱신 요청
      const response = await apiClient.post('/auth/refresh', {
        refreshToken: refreshToken
      });

      // 새로운 토큰 저장
      await this.setAccessToken(response.data.accessToken);
      await this.setRefreshToken(response.data.refreshToken);

      console.log('[SecureDataSource] 토큰 갱신 성공');
      return true;
    } catch (error) {
      this.logError('토큰 갱신 중 오류 발생', error);

      // 특정 에러에 대한 추가 처리
      if (axios.isAxiosError(error)) {
        if (error.code === 'NETWORK_ERROR' || error.message === 'Network Error') {
          console.log('[SecureDataSource] 네트워크 오류 - 서버 연결 불가');
        } else if (error.response?.status === 401 || error.response?.status === 403) {
          console.log('[SecureDataSource] 리프레시 토큰 만료 또는 유효하지 않음');
          // 리프레시 토큰도 만료된 경우 모든 토큰 삭제
          await this.clearTokens();
        }
      }

      return false;
    }
  }

  /**
   * 토큰 확인 및 필요시 갱신
   * @returns 유효한 토큰이 있으면 true, 없으면 false
   * @description 토큰의 유효성을 확인하고, 만료된 경우 갱신을 시도합니다.
   */
  async ensureValidToken(): Promise<boolean> {
    // 토큰 유효성 확인
    const isValid = await this.isTokenValid();

    if (isValid) {
      return true; // 토큰이 유효하면 그대로 사용
    }

    // 토큰이 유효하지 않으면 갱신 시도
    const isRefreshed = await this.refreshTokens();

    if (isRefreshed) {
      return true; // 갱신 성공
    }

    // 갱신도 실패하면 토큰 삭제
    await this.clearTokens();
    return false;
  }

  async updateUser(): Promise<any> {
    try {
      const accessToken = await this.getAccessToken();

      if (!accessToken) {
        console.log('[SecureDataSource] 토큰이 존재하지 않습니다.');
        return false;
      }

      const response = await apiClient.get('/user/profile', {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      });

      return response;
    } catch (error) {
      this.logError('사용자 정보 업데이트 실패', error);
      this.refreshTokens();
      return false;
    }
  }
}

