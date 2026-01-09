/**
 * FCM 알림 수신 처리 서비스 (기존 구조 통합 버전)
 * 실제 푸시 알림이 왔을 때의 처리를 담당합니다.
 * 토스트 표시와 알림 ON/OFF 기능이 추가되었습니다.
 */

import messaging, { 
  FirebaseMessagingTypes, 
  onMessage, 
  onNotificationOpenedApp, 
  getInitialNotification, 
  setBackgroundMessageHandler,
  getMessaging
} from '@react-native-firebase/messaging';
import { Platform } from 'react-native';
import { secureDataSource } from '../index';
import { NotificationLocalDataSource } from '../local/NotificationLocalDataSource';
import { remoteDataSource } from '../index';
import { ToastManagerRef } from '../../../component/toast/ToastManager';

export class FCMNotificationHandler {
  private foregroundUnsubscribe: (() => void) | null = null;
  private backgroundUnsubscribe: (() => void) | null = null;
  private toastManagerRef: React.RefObject<ToastManagerRef | null> | null = null;
  private notificationLocalDataSource: NotificationLocalDataSource;

  constructor() {
    this.notificationLocalDataSource = NotificationLocalDataSource.getInstance();
  }

  /**
   * 에러 로깅
   */
  private logError(context: string, error: any): void {
    console.log(`[FCMNotificationHandler] ${context}:`, {
      message: error.message,
      code: error.code,
      stack: error.stack,
    });
  }

  /**
   * 토스트 매니저 참조 설정
   */
  setToastManagerRef(ref: React.RefObject<ToastManagerRef | null>) {
    this.toastManagerRef = ref;
  }

  /**
   * 알림 리스너들을 설정합니다
   * 앱 시작 시 한 번만 호출하세요
   */
  async setupNotificationListeners() {
    try {
      // FCM 토큰 초기화
      await secureDataSource.getFcmToken();

      const messagingInstance = getMessaging();

      // 1. 포그라운드에서 알림 수신
      this.foregroundUnsubscribe = onMessage(messagingInstance, async (remoteMessage) => {
        console.log('[FCMNotificationHandler] 포그라운드에서 알림 수신:', remoteMessage);

        // 알림이 활성화되어 있는지 확인
        const isEnabled = await secureDataSource.isNotificationEnabled();
        if (isEnabled) {
          this.handleForegroundNotification(remoteMessage);
        } else {
          console.log('[FCMNotificationHandler] 알림이 비활성화되어 있어 표시하지 않습니다.');
        }
      });

      // 2. 백그라운드에서 알림 클릭으로 앱 열기
      this.backgroundUnsubscribe = onNotificationOpenedApp(messagingInstance, (remoteMessage) => {
        console.log('[FCMNotificationHandler] 백그라운드에서 알림 클릭으로 앱 열기:', remoteMessage);
        this.handleNotificationOpen(remoteMessage);
      });

      // 3. 앱이 완전히 종료된 상태에서 알림으로 앱 열기
      getInitialNotification(messagingInstance)
        .then((remoteMessage) => {
          if (remoteMessage) {
            console.log('[FCMNotificationHandler] 앱 종료 상태에서 알림으로 앱 열기:', remoteMessage);
            this.handleNotificationOpen(remoteMessage);
          }
        })
        .catch((error) => {
          this.logError('초기 알림 처리 실패', error);
        });

      // 4. 백그라운드에서 알림 수신 (앱이 열리지 않은 상태)
      setBackgroundMessageHandler(messagingInstance, async (remoteMessage) => {
        console.log('[FCMNotificationHandler] 백그라운드에서 알림 수신 (앱 닫힌 상태):', remoteMessage);
        this.handleBackgroundNotification(remoteMessage);
      });

      // 5. FCM 토큰 새로고침 리스너
      secureDataSource.onTokenRefresh((token) => {
        console.log('[FCMNotificationHandler] FCM 토큰이 새로고침되었습니다:', token);
        // 서버에 새 토큰 전송
        this.handleTokenRefresh(token);
      });

      console.log('[FCMNotificationHandler] 모든 알림 리스너 설정 완료');
    } catch (error) {
      this.logError('알림 리스너 설정 실패', error);
      throw error;
    }
  }

  /**
   * 토큰 새로고침 처리
   */
  private async handleTokenRefresh(token: string) {
    try {
      // 로컬에 새 토큰 저장
      await secureDataSource.setFcmToken(token);
      
      // 서버에 새 토큰 전송
      await remoteDataSource.updateFcmToken(token);
      
      // 콜백 호출
      this.onTokenUpdated?.(token);
    } catch (error) {
      this.logError('토큰 새로고침 처리 실패', error);
    }
  }

  /**
   * 토큰 업데이트 콜백 (서버 전송용)
   */
  onTokenUpdated?: (token: string) => void;

  /**
   * 포그라운드에서 알림을 받았을 때 처리
   * 앱이 실행 중일 때 알림이 온 경우 - 커스텀 토스트로 표시
   */
  private async handleForegroundNotification(remoteMessage: FirebaseMessagingTypes.RemoteMessage) {
    try {
      const { notification, data } = remoteMessage;

      // 알림 히스토리에 저장
      await this.saveNotificationToHistory(remoteMessage, false);

      // 토스트로 알림 표시
      if (this.toastManagerRef?.current) {
        this.toastManagerRef.current.showNotificationToast(
          remoteMessage,
          () => {
            // 토스트 클릭 시 처리
            console.log('[FCMNotificationHandler] 토스트 클릭됨');
            this.handleNotificationAction(data);
          }
        );
      }

      // 추가 데이터 처리
      if (data) {
        console.log('[FCMNotificationHandler] 알림 데이터:', data);
        this.processNotificationData(data);
      }
    } catch (error) {
      this.logError('포그라운드 알림 처리 실패', error);
    }
  }

  /**
   * 알림 클릭으로 앱이 열렸을 때 처리
   * 백그라운드나 종료 상태에서 알림 클릭한 경우
   */
  private async handleNotificationOpen(remoteMessage: FirebaseMessagingTypes.RemoteMessage) {
    try {
      const { notification, data } = remoteMessage;

      console.log('[FCMNotificationHandler] 알림으로 앱 열기:', {
        title: notification?.title,
        body: notification?.body,
        data: data
      });

      // 알림 히스토리에 저장 (열림 상태로)
      await this.saveNotificationToHistory(remoteMessage, true);

      // 특정 화면으로 이동 (navigation 필요)
      if (data) {
        this.navigateBasedOnNotification(data);
      }
    } catch (error) {
      this.logError('알림 열기 처리 실패', error);
    }
  }

  /**
   * 백그라운드에서 알림을 받았을 때 처리 (앱이 닫힌 상태)
   * 주로 데이터 동기화나 로컬 알림 예약 등에 사용
   */
  private async handleBackgroundNotification(remoteMessage: FirebaseMessagingTypes.RemoteMessage) {
    try {
      console.log('[FCMNotificationHandler] 백그라운드 알림 처리:', remoteMessage);

      // 알림 히스토리에 저장
      await this.saveNotificationToHistory(remoteMessage, false);

      // 백그라운드에서 할 작업들
      // - 데이터 동기화
      // - 로컬 저장소 업데이트
      // - 배지 카운트 업데이트 등
    } catch (error) {
      this.logError('백그라운드 알림 처리 실패', error);
    }
  }

  /**
   * 알림 데이터에 따른 네비게이션 처리
   */
  private navigateBasedOnNotification(data: { [key: string]: string | object }) {
    // 타입 가드를 통한 안전한 데이터 접근
    const notificationData = data as { [key: string]: string };

    // 데이터에 따른 화면 이동 예시
    switch (notificationData.type) {
      case 'chat':
        // 채팅방으로 이동
        // navigation.navigate('ChatRoom', { roomId: notificationData.roomId });
        console.log('[FCMNotificationHandler] 채팅방으로 이동:', notificationData.roomId);
        break;

      case 'order':
        // 주문 상세로 이동
        // navigation.navigate('OrderDetail', { orderId: notificationData.orderId });
        console.log('[FCMNotificationHandler] 주문 상세로 이동:', notificationData.orderId);
        break;

      case 'announcement':
        // 공지사항으로 이동
        // navigation.navigate('Notice', { noticeId: notificationData.noticeId });
        console.log('[FCMNotificationHandler] 공지사항으로 이동:', notificationData.noticeId);
        break;

      default:
        // 기본 메인 화면으로 이동
        // navigation.navigate('Main');
        console.log('[FCMNotificationHandler] 메인 화면으로 이동');
        break;
    }

    // 네비게이션 콜백 호출 (필요시 설정)
    this.onNavigationRequested?.(notificationData);
  }

  /**
   * 알림을 히스토리에 저장합니다
   */
  private async saveNotificationToHistory(
    remoteMessage: FirebaseMessagingTypes.RemoteMessage,
    isOpened: boolean = false
  ): Promise<void> {
    try {
      const { notification, data } = remoteMessage;

      const result = await this.notificationLocalDataSource.addNotificationToHistory({
        title: notification?.title || '알림',
        body: notification?.body || '새로운 메시지가 있습니다.',
        type: (data?.type as string) || 'general',
        data: data ? (data as { [key: string]: string }) : {},
        isOpened,
      });

      if (result) {
        console.log('[FCMNotificationHandler] 알림이 히스토리에 저장됨');
      } else {
        console.warn('[FCMNotificationHandler] 알림 히스토리 저장 실패');
      }
    } catch (error) {
      this.logError('알림 히스토리 저장 실패', error);
    }
  }

  /**
   * 네비게이션 콜백 (외부에서 설정)
   */
  onNavigationRequested?: (data: { [key: string]: string }) => void;

  /**
   * 알림 액션 처리 (포그라운드에서 알림 클릭 시)
   */
  private handleNotificationAction(data: { [key: string]: string | object } | undefined) {
    if (data) {
      this.processNotificationData(data);
      this.navigateBasedOnNotification(data);
    }
  }

  /**
   * 알림 데이터 처리 (비즈니스 로직)
   */
  private processNotificationData(data: { [key: string]: string | object }) {
    // 알림 데이터에 따른 처리
    // 예: 채팅 메시지 수 업데이트, 배지 카운트 업데이트 등

    console.log('[FCMNotificationHandler] 알림 데이터 처리:', data);

    // 예시: 읽지 않은 메시지 수 업데이트
    if (data.unreadCount) {
      // 앱 아이콘 배지 업데이트나 상태 관리
      this.onDataProcessed?.(data);
    }
  }

  /**
   * 데이터 처리 콜백 (외부에서 설정)
   */
  onDataProcessed?: (data: { [key: string]: string | object }) => void;

  /**
   * 알림 활성화/비활성화 설정
   */
  async setNotificationEnabled(enabled: boolean): Promise<void> {
    try {
      await secureDataSource.setNotificationEnabled(enabled);
      console.log('[FCMNotificationHandler] 알림 설정 변경됨:', enabled);
    } catch (error) {
      this.logError('알림 설정 변경 실패', error);
      throw error;
    }
  }

  /**
   * 알림 활성화 상태 확인
   */
  async isNotificationEnabled(): Promise<boolean> {
    return await secureDataSource.isNotificationEnabled();
  }

  /**
   * FCM 토큰 가져오기
   */
  async getFcmToken(): Promise<string | null> {
    return await secureDataSource.getStoredFcmToken();
  }

  /**
   * FCM 토큰을 서버에 등록
   */
  async registerFcmTokenToServer(token: string): Promise<void> {
    try {
      await remoteDataSource.registerFcmToken(token);
      console.log('[FCMNotificationHandler] FCM 토큰 서버 등록 성공');
    } catch (error) {
      this.logError('FCM 토큰 서버 등록 실패', error);
      throw error;
    }
  }

  /**
   * FCM 토큰을 서버에서 해제
   * TODO: 서버에 해제 API가 구현되면 주석 해제
   */
  async unregisterFcmTokenFromServer(): Promise<void> {
    // 서버에 해제 API가 없으므로 빈 함수로 처리
    console.log('[FCMNotificationHandler] FCM 토큰 서버 해제 기능 비활성화 (서버 API 미구현)');
    // try {
    //   await remoteDataSource.unregisterFcmToken();
    //   console.log('[FCMNotificationHandler] FCM 토큰 서버 해제 성공');
    // } catch (error) {
    //   this.logError('FCM 토큰 서버 해제 실패', error);
    //   throw error;
    // }
  }

  /**
   * 알림 리스너 해제 (앱 종료나 로그아웃 시)
   */
  removeNotificationListeners() {
    try {
      if (this.foregroundUnsubscribe) {
        this.foregroundUnsubscribe();
        this.foregroundUnsubscribe = null;
      }

      if (this.backgroundUnsubscribe) {
        this.backgroundUnsubscribe();
        this.backgroundUnsubscribe = null;
      }

      console.log('[FCMNotificationHandler] 모든 알림 리스너 해제');
    } catch (error) {
      this.logError('알림 리스너 해제 실패', error);
    }
  }

  /**
   * 현재 등록된 리스너 상태 확인
   */
  isListenersActive(): boolean {
    return !!(this.foregroundUnsubscribe && this.backgroundUnsubscribe);
  }
}

// 싱글톤 인스턴스
export const fcmNotificationHandler = new FCMNotificationHandler();
