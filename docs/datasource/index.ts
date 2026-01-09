/**
 * DataSource의 통합 관리를 위한 인덱스 파일
 * 이 파일은 각 데이터 소스를 하나로 통합하여 사용할 수 있게 합니다.
 */

import { RemoteDataSource } from './remote/RemoteDataSource.ts';
import { LocalDataSource } from './local/LocalDataSource.ts';
import { SecureDataSource } from './secure/SecureDataSource.ts';

// 데이터 소스 싱글톤 인스턴스
export const remoteDataSource = new RemoteDataSource();
export const localDataSource = new LocalDataSource();
export const secureDataSource = new SecureDataSource();

// 통합 데이터 소스 객체
export const DaodaDataSource = {
  remote: remoteDataSource,
  local: localDataSource,
  secure: secureDataSource,
};

export default DaodaDataSource;
