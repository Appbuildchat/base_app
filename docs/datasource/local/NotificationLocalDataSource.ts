/**
 * 알림 관련 로컬 데이터 소스 클래스
 * 알림 설정과 히스토리를 로컬에 저장하고 관리합니다
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import { AlarmSettings, NotificationHistoryItem } from '../../type/notificationTypes';

const STORAGE_KEYS = {
  ALARM_SETTINGS: '@alarm_settings',
  ALARM_HISTORY: '@alarm_history',
};

const MAX_HISTORY_COUNT = 100; // 최대 100개 히스토리 저장

export class NotificationLocalDataSource {
  private static instance: NotificationLocalDataSource;
  private isUpdatingHistory: boolean = false; // 히스토리 업데이트 중 플래그

  public static getInstance(): NotificationLocalDataSource {
    if (!NotificationLocalDataSource.instance) {
      NotificationLocalDataSource.instance = new NotificationLocalDataSource();
    }
    return NotificationLocalDataSource.instance;
  }

  /**
   * 에러 로깅
   */
  private logError(context: string, error: any): void {
    console.log(`[NotificationLocalDataSource] ${context}:`, error);
  }

  /**
   * 동시성 제어를 위한 락 획득
   */
  private async acquireLock(): Promise<boolean> {
    if (this.isUpdatingHistory) {
      // 이미 업데이트 중이면 잠시 대기
      await new Promise<void>(resolve => setTimeout(resolve, 100));
      return this.acquireLock();
    }
    this.isUpdatingHistory = true;
    return true;
  }

  /**
   * 락 해제
   */
  private releaseLock(): void {
    this.isUpdatingHistory = false;
  }

  /**
   * 고유 ID 생성
   */
  private generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 기본 알림 설정값
   */
  private getDefaultAlarmSettings(): AlarmSettings {
    return {
      pushNotificationEnabled: true,
      chatNotificationEnabled: true,
      orderNotificationEnabled: true,
      marketingNotificationEnabled: false,
    };
  }

  /**
   * 데이터 저장
   */
  private async setItem<T>(key: string, value: T): Promise<boolean> {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
      console.log(`[NotificationLocalDataSource] 데이터 저장 성공: ${key}`);
      return true;
    } catch (error) {
      this.logError(`데이터 저장 실패: ${key}`, error);
      return false;
    }
  }

  /**
   * 데이터 조회
   */
  private async getItem<T>(key: string): Promise<T | null> {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      if (jsonValue === null) {
        return null;
      }
      return JSON.parse(jsonValue) as T;
    } catch (error) {
      this.logError(`데이터 조회 실패: ${key}`, error);
      return null;
    }
  }

  // === 알림 설정 관련 메서드들 ===

  /**
   * 알림 설정을 저장합니다
   */
  async saveAlarmSettings(settings: AlarmSettings): Promise<boolean> {
    return this.setItem(STORAGE_KEYS.ALARM_SETTINGS, settings);
  }

  /**
   * 알림 설정을 가져옵니다
   */
  async getAlarmSettings(): Promise<AlarmSettings> {
    try {
      const settings = await this.getItem<AlarmSettings>(STORAGE_KEYS.ALARM_SETTINGS);
      if (settings) {
        // 기본값과 병합하여 누락된 설정 보완
        return { ...this.getDefaultAlarmSettings(), ...settings };
      }
      return this.getDefaultAlarmSettings();
    } catch (error) {
      this.logError('알림 설정 가져오기 실패', error);
      return this.getDefaultAlarmSettings();
    }
  }

  /**
   * 특정 알림 설정을 업데이트합니다
   */
  async updateAlarmSetting<K extends keyof AlarmSettings>(
    key: K,
    value: AlarmSettings[K]
  ): Promise<boolean> {
    try {
      const currentSettings = await this.getAlarmSettings();
      const updatedSettings = { ...currentSettings, [key]: value };
      return await this.saveAlarmSettings(updatedSettings);
    } catch (error) {
      this.logError('알림 설정 업데이트 실패', error);
      return false;
    }
  }

  /**
   * 알림 설정을 초기화합니다
   */
  async resetAlarmSettings(): Promise<boolean> {
    return this.saveAlarmSettings(this.getDefaultAlarmSettings());
  }

  // === 알림 히스토리 관련 메서드들 ===

  /**
   * 새로운 알림을 히스토리에 추가합니다
   */
  async addNotificationToHistory(notification: Omit<NotificationHistoryItem, 'id' | 'receivedAt' | 'isRead'>): Promise<NotificationHistoryItem | null> {
    try {
      // 락 획득
      await this.acquireLock();
      
      const currentHistory = await this.getNotificationHistory();
      
      const newItem: NotificationHistoryItem = {
        id: this.generateId(),
        ...notification,
        receivedAt: new Date().toISOString(),
        isRead: false,
      };

      // 새 알림을 맨 앞에 추가
      const updatedHistory = [newItem, ...currentHistory];
      
      // 최대 개수 제한
      const limitedHistory = updatedHistory.slice(0, MAX_HISTORY_COUNT);
      
      const success = await this.setItem(STORAGE_KEYS.ALARM_HISTORY, limitedHistory);
      if (success) {
        console.log('[NotificationLocalDataSource] 알림 히스토리에 추가됨:', newItem);
        return newItem;
      }
      return null;
    } catch (error) {
      this.logError('알림 히스토리 추가 실패', error);
      return null;
    } finally {
      // 락 해제
      this.releaseLock();
    }
  }

  /**
   * 알림 히스토리를 가져옵니다
   */
  async getNotificationHistory(): Promise<NotificationHistoryItem[]> {
    try {
      const history = await this.getItem<NotificationHistoryItem[]>(STORAGE_KEYS.ALARM_HISTORY);
      return history || [];
    } catch (error) {
      this.logError('알림 히스토리 가져오기 실패', error);
      return [];
    }
  }

  /**
   * 특정 알림을 읽음 처리합니다
   */
  async markNotificationAsRead(id: string): Promise<boolean> {
    try {
      const history = await this.getNotificationHistory();
      const updatedHistory = history.map(item => 
        item.id === id ? { ...item, isRead: true } : item
      );
      
      return await this.setItem(STORAGE_KEYS.ALARM_HISTORY, updatedHistory);
    } catch (error) {
      this.logError('알림 읽음 처리 실패', error);
      return false;
    }
  }

  /**
   * 특정 알림을 열림 처리합니다
   */
  async markNotificationAsOpened(id: string): Promise<boolean> {
    try {
      const history = await this.getNotificationHistory();
      const updatedHistory = history.map(item => 
        item.id === id ? { ...item, isRead: true, isOpened: true } : item
      );
      
      return await this.setItem(STORAGE_KEYS.ALARM_HISTORY, updatedHistory);
    } catch (error) {
      this.logError('알림 열림 처리 실패', error);
      return false;
    }
  }

  /**
   * 모든 알림을 읽음 처리합니다
   */
  async markAllNotificationsAsRead(): Promise<boolean> {
    try {
      const history = await this.getNotificationHistory();
      const updatedHistory = history.map(item => ({ ...item, isRead: true }));
      
      return await this.setItem(STORAGE_KEYS.ALARM_HISTORY, updatedHistory);
    } catch (error) {
      this.logError('모든 알림 읽음 처리 실패', error);
      return false;
    }
  }

  /**
   * 특정 알림을 삭제합니다
   */
  async deleteNotification(id: string): Promise<boolean> {
    try {
      const history = await this.getNotificationHistory();
      const updatedHistory = history.filter(item => item.id !== id);
      
      return await this.setItem(STORAGE_KEYS.ALARM_HISTORY, updatedHistory);
    } catch (error) {
      this.logError('알림 삭제 실패', error);
      return false;
    }
  }

  /**
   * 알림 히스토리를 모두 삭제합니다
   */
  async clearNotificationHistory(): Promise<boolean> {
    return this.setItem(STORAGE_KEYS.ALARM_HISTORY, []);
  }

  /**
   * 읽지 않은 알림 개수를 가져옵니다
   */
  async getUnreadNotificationCount(): Promise<number> {
    try {
      const history = await this.getNotificationHistory();
      return history.filter(item => !item.isRead).length;
    } catch (error) {
      this.logError('읽지 않은 알림 개수 조회 실패', error);
      return 0;
    }
  }

  /**
   * 날짜별로 알림 히스토리를 그룹화합니다
   */
  async getNotificationHistoryGroupedByDate(): Promise<{ [date: string]: NotificationHistoryItem[] }> {
    try {
      const history = await this.getNotificationHistory();
      const grouped: { [date: string]: NotificationHistoryItem[] } = {};

      history.forEach(item => {
        const date = new Date(item.receivedAt).toLocaleDateString('ko-KR');
        if (!grouped[date]) {
          grouped[date] = [];
        }
        grouped[date].push(item);
      });

      return grouped;
    } catch (error) {
      this.logError('날짜별 알림 히스토리 그룹화 실패', error);
      return {};
    }
  }

  /**
   * 특정 타입의 알림 히스토리를 가져옵니다
   */
  async getNotificationHistoryByType(type: string): Promise<NotificationHistoryItem[]> {
    try {
      const history = await this.getNotificationHistory();
      return history.filter(item => item.type === type);
    } catch (error) {
      this.logError('타입별 알림 히스토리 조회 실패', error);
      return [];
    }
  }
}
