/**
 * 로컬 데이터 소스 클래스
 * AsyncStorage를 사용하여 로컬 데이터를 관리하는 클래스입니다.
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import {ICorpUserType, IUserType} from '../../../../feature/profile/data/type/userState.ts';

// 저장할 키의 상수 정의
const STORAGE_KEYS = {
  USER_INFO: 'user_info',
  USER_SETTINGS: 'user_settings',
  CACHE_PREFIX: 'cache_',
};

export class LocalDataSource {
  /**
   * 데이터 저장
   * @param key 저장 키
   * @param value 저장할 데이터
   */
  async setItem<T>(key: string, value: T): Promise<boolean> {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
      console.log(`[LocalDataSource] 데이터 저장 성공: ${key}`);
      return true;
    } catch (error) {
      console.log(`[LocalDataSource] 데이터 저장 실패: ${key}`, error);
      return false;
    }
  }

  /**
   * 데이터 조회
   * @param key 조회할 키
   */
  async getItem<T>(key: string): Promise<T | null> {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      if (jsonValue === null) {
        return null;
      }
      return JSON.parse(jsonValue) as T;
    } catch (error) {
      console.log(`[LocalDataSource] 데이터 조회 실패: ${key}`, error);
      return null;
    }
  }

  /**
   * 데이터 삭제
   * @param key 삭제할 키
   */
  async removeItem(key: string): Promise<boolean> {
    try {
      await AsyncStorage.removeItem(key);
      console.log(`[LocalDataSource] 데이터 삭제 성공: ${key}`);
      return true;
    } catch (error) {
      console.log(`[LocalDataSource] 데이터 삭제 실패: ${key}`, error);
      return false;
    }
  }

  /**
   * 모든 데이터 삭제
   */
  async clearAll(): Promise<boolean> {
    try {
      await AsyncStorage.clear();
      console.log('[LocalDataSource] 모든 데이터 삭제 성공');
      return true;
    } catch (error) {
      console.log('[LocalDataSource] 모든 데이터 삭제 실패', error);
      return false;
    }
  }

  /**
   * 사용자 정보 저장
   * @param userInfo 사용자 정보 객체
   */
  async setUserInfo(userInfo: IUserType): Promise<boolean> {
    if (userInfo.userRole == "ENTERPRISE") {}
    return this.setItem(STORAGE_KEYS.USER_INFO, userInfo);
  }

  /**
   * 사용자 정보 조회
   */
  async getUserInfo<T>(): Promise<T | null> {
    return this.getItem<T>(STORAGE_KEYS.USER_INFO);
  }

  /**
   * 사용자 설정 저장
   * @param settings 사용자 설정 객체
   */
  async setUserSettings(settings: any): Promise<boolean> {
    return this.setItem(STORAGE_KEYS.USER_SETTINGS, settings);
  }

  /**
   * 사용자 설정 조회
   */
  async getUserSettings<T>(): Promise<T | null> {
    return this.getItem<T>(STORAGE_KEYS.USER_SETTINGS);
  }

  /**
   * 캐시 데이터 저장
   * @param key 캐시 키
   * @param value 저장할 데이터
   * @param expiryMinutes 만료 시간(분)
   */
  async setCacheItem<T>(key: string, value: T, expiryMinutes: number = 30): Promise<boolean> {
    const cacheKey = `${STORAGE_KEYS.CACHE_PREFIX}${key}`;
    const cacheData = {
      value,
      expiry: Date.now() + expiryMinutes * 60 * 1000,
    };
    return this.setItem(cacheKey, cacheData);
  }

  /**
   * 캐시 데이터 조회
   * @param key 캐시 키
   */
  async getCacheItem<T>(key: string): Promise<T | null> {
    const cacheKey = `${STORAGE_KEYS.CACHE_PREFIX}${key}`;
    const cacheData = await this.getItem<{ value: T; expiry: number }>(cacheKey);

    if (!cacheData) {
      return null;
    }

    // 만료 여부 확인
    if (Date.now() > cacheData.expiry) {
      await this.removeItem(cacheKey);
      return null;
    }

    return cacheData.value;
  }

  /**
   * 캐시 데이터 삭제
   * @param key 캐시 키
   */
  async removeCacheItem(key: string): Promise<boolean> {
    const cacheKey = `${STORAGE_KEYS.CACHE_PREFIX}${key}`;
    return this.removeItem(cacheKey);
  }

  /**
   * 모든 캐시 데이터 삭제
   */
  async clearAllCache(): Promise<void> {
    try {
      const keys = await AsyncStorage.getAllKeys();
      const cacheKeys = keys.filter(key => key.startsWith(STORAGE_KEYS.CACHE_PREFIX));
      if (cacheKeys.length > 0) {
        await AsyncStorage.multiRemove(cacheKeys);
      }
      console.log('[LocalDataSource] 모든 캐시 데이터 삭제 성공');
    } catch (error) {
      console.log('[LocalDataSource] 모든 캐시 데이터 삭제 실패', error);
    }
  }
}
