/**
 * 설정 관련 로컬 데이터 소스 클래스
 * 앱 설정(테마, 알림 등)을 로컬에 저장하고 관리합니다
 */

import AsyncStorage from '@react-native-async-storage/async-storage';

const STORAGE_KEYS = {
  SETTING_DATA: '@setting_data',
};

export interface SettingData {
  isNoticeAvailable: boolean;
  theme: 'light' | 'dark' | 'follow';
}

export class SettingLocalDataSource {
  private static instance: SettingLocalDataSource;

  public static getInstance(): SettingLocalDataSource {
    if (!SettingLocalDataSource.instance) {
      SettingLocalDataSource.instance = new SettingLocalDataSource();
    }
    return SettingLocalDataSource.instance;
  }

  /**
   * 에러 로깅
   */
  private logError(context: string, error: any): void {
    console.log(`[SettingLocalDataSource] ${context}:`, error);
  }

  /**
   * 기본 설정값
   */
  private getDefaultSettings(): SettingData {
    return {
      isNoticeAvailable: false,
      theme: 'light',
    };
  }

  /**
   * 데이터 저장
   */
  private async setItem<T>(key: string, value: T): Promise<boolean> {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
      console.log(`[SettingLocalDataSource] 데이터 저장 성공: ${key}`);
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

  /**
   * 설정을 저장합니다
   */
  async saveSettings(settings: SettingData): Promise<boolean> {
    return this.setItem(STORAGE_KEYS.SETTING_DATA, settings);
  }

  /**
   * 설정을 가져옵니다
   */
  async getSettings(): Promise<SettingData> {
    try {
      const settings = await this.getItem<SettingData>(STORAGE_KEYS.SETTING_DATA);
      if (settings) {
        // 기본값과 병합하여 누락된 설정 보완
        return { ...this.getDefaultSettings(), ...settings };
      }
      return this.getDefaultSettings();
    } catch (error) {
      this.logError('설정 가져오기 실패', error);
      return this.getDefaultSettings();
    }
  }

  /**
   * 특정 설정을 업데이트합니다
   */
  async updateSetting<K extends keyof SettingData>(
    key: K,
    value: SettingData[K]
  ): Promise<boolean> {
    try {
      const currentSettings = await this.getSettings();
      const updatedSettings = { ...currentSettings, [key]: value };
      return await this.saveSettings(updatedSettings);
    } catch (error) {
      this.logError('설정 업데이트 실패', error);
      return false;
    }
  }

  /**
   * 설정을 초기화합니다
   */
  async resetSettings(): Promise<boolean> {
    return this.saveSettings(this.getDefaultSettings());
  }

  /**
   * 테마만 업데이트합니다
   */
  async updateTheme(theme: 'light' | 'dark' | 'follow'): Promise<boolean> {
    return this.updateSetting('theme', theme);
  }

  /**
   * 알림 설정만 업데이트합니다
   */
  async updateNoticeAvailable(isAvailable: boolean): Promise<boolean> {
    return this.updateSetting('isNoticeAvailable', isAvailable);
  }
}
