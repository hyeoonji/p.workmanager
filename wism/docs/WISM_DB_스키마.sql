-- =====================================================================
--  WISM (Wintek Insight System Manager) — DB Schema
--  Engine : MySQL 8.0 / MariaDB 10.5+  (utf8mb4)
--  대상   : 개발용 AWS 임시 서버
--  버전   : v0.1 (2026-06-06)
--
--  [운영(홈페이지 DB) 이전 시 주의]
--   - wintek_user   → 기존 직원(임직원) 테이블로 대체/매핑 (신규 생성 X)
--   - wintek_project→ 기존 사업 데이터(사업명↔주관업체)로 대체/매핑
--   - 그 외 wintek_* 테이블만 홈페이지 DB에 신규 추가 요청
--   - ENUM 한글값은 운영 정책에 따라 코드값(영문/숫자)+룩업테이블로 바꿀 수 있음
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- 1) 사용자  (담당자 검색 대상 = 전체 직원, 로그인 = role in('manager','admin'))
--    운영: 기존 직원 테이블로 대체. 개발용 스탠드인.
-- =====================================================================
CREATE TABLE wintek_user (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  employee_no   VARCHAR(20)  NOT NULL                COMMENT '사번(로그인 ID)',
  name          VARCHAR(50)  NOT NULL,
  email         VARCHAR(120) NULL,
  phone         VARCHAR(20)  NULL,
  position      VARCHAR(50)  NULL                    COMMENT '직급 (예: 주임연구원, 팀장)',
  dept          VARCHAR(80)  NULL                    COMMENT '부서 (예: 사업 5실 3팀)',
  photo_url     VARCHAR(255) NULL                    COMMENT '회사 내부 서버 사진 URL 연동(읽기 전용, 앱에서 수정 불가)',
  role          VARCHAR(20)  NOT NULL DEFAULT 'employee'
                             COMMENT 'employee=일반(태그 대상)/manager=앱 사용자/admin=상위. 1차는 단일등급',
  password_hash VARCHAR(255) NULL                    COMMENT '개발용 로그인. 운영은 기존 인증 사용',
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_employee_no (employee_no),
  KEY idx_user_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자(직원)';

-- =====================================================================
-- 2) 사업/프로젝트  (사업명 ↔ 주관업체)
--    운영: 기존 사업 데이터로 대체. 1차는 읽기 전용 조회.
-- =====================================================================
CREATE TABLE wintek_project (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  name        VARCHAR(150) NOT NULL                  COMMENT '사업명',
  client_name VARCHAR(150) NULL                      COMMENT '주관업체',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_project_name (name),
  KEY idx_project_client (client_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업(프로젝트)';

-- =====================================================================
-- 3) 메모 (핵심)
--    readBy  = wintek_read_receipt 의 COUNT (파생, 컬럼 저장 X)
--    bookmarked / isRead = 조회 사용자 기준으로 JOIN 계산
-- =====================================================================
CREATE TABLE wintek_memo (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  title          VARCHAR(200) NOT NULL,
  content        TEXT         NULL,
  priority       ENUM('긴급','일반')                         NOT NULL DEFAULT '일반',
  category       ENUM('일정','이슈','결정사항','회의록','기타') NOT NULL DEFAULT '기타',
  project_id     BIGINT       NULL                    COMMENT 'wintek_project FK (선택)',
  scheduled_date DATE         NULL                    COMMENT 'category=일정 일 때 캘린더 표시',
  author_id      BIGINT       NOT NULL,
  total_readers  INT          NOT NULL DEFAULT 0      COMMENT '읽음확인 분모: 작성 시점 활성 관리자 수(is_active=1 & role in manager/admin) 스냅샷, 작성자 포함',
  view_count     INT          NOT NULL DEFAULT 0      COMMENT '조회수=읽음확인 누른 인원(사람당 1회, 작성자 제외). 읽음확인 시에만 증가',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_memo_category  (category),
  KEY idx_memo_priority  (priority),
  KEY idx_memo_author    (author_id),
  KEY idx_memo_project   (project_id),
  KEY idx_memo_scheduled (scheduled_date),
  KEY idx_memo_created    (created_at),
  FULLTEXT KEY ftx_memo (title, content)             COMMENT '통합 검색용(선택). 미사용 시 LIKE',
  CONSTRAINT fk_memo_author  FOREIGN KEY (author_id)  REFERENCES wintek_user(id),
  CONSTRAINT fk_memo_project FOREIGN KEY (project_id) REFERENCES wintek_project(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='메모';

-- =====================================================================
-- 4) 메모 담당자 태그  (M:N  memo ↔ user)  / 멘션 알림 대상
-- =====================================================================
CREATE TABLE wintek_memo_assignee (
  memo_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  PRIMARY KEY (memo_id, user_id),
  KEY idx_assignee_user (user_id),
  CONSTRAINT fk_assignee_memo FOREIGN KEY (memo_id) REFERENCES wintek_memo(id) ON DELETE CASCADE,
  CONSTRAINT fk_assignee_user FOREIGN KEY (user_id) REFERENCES wintek_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='메모 담당자 태그';

-- =====================================================================
-- 5) 댓글  (type: comment=일반 / status=확인완료)
-- =====================================================================
CREATE TABLE wintek_comment (
  id         BIGINT NOT NULL AUTO_INCREMENT,
  memo_id    BIGINT NOT NULL,
  author_id  BIGINT NOT NULL,
  content    TEXT   NOT NULL,
  type       ENUM('comment','status') NOT NULL DEFAULT 'comment',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_comment_memo (memo_id),
  CONSTRAINT fk_comment_memo   FOREIGN KEY (memo_id)   REFERENCES wintek_memo(id) ON DELETE CASCADE,
  CONSTRAINT fk_comment_author FOREIGN KEY (author_id) REFERENCES wintek_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='댓글';

-- =====================================================================
-- 6) 첨부파일
--    저장: 홈페이지 서버 디스크(storage_path), 다운로드는 인증 필요
--    제약(파일당 10MB / 메모당 3개 / 허용형식: 이미지·PDF·HWP·Word·PPT·Excel)
--    은 API/앱 레이어에서 검증 (DB 강제 X)
-- =====================================================================
CREATE TABLE wintek_attachment (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  memo_id      BIGINT       NOT NULL,
  file_name    VARCHAR(255) NOT NULL                 COMMENT '원본 파일명',
  mime_type    VARCHAR(100) NULL,
  size_bytes   BIGINT       NOT NULL DEFAULT 0,
  storage_path VARCHAR(500) NOT NULL                 COMMENT '서버 디스크 저장 경로',
  uploaded_by  BIGINT       NULL,
  uploaded_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attachment_memo (memo_id),
  CONSTRAINT fk_attachment_memo FOREIGN KEY (memo_id) REFERENCES wintek_memo(id) ON DELETE CASCADE,
  CONSTRAINT fk_attachment_user FOREIGN KEY (uploaded_by) REFERENCES wintek_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='첨부파일';

-- =====================================================================
-- 7) 읽음 확인  (readBy 카운트 = 이 테이블의 행 수)
-- =====================================================================
CREATE TABLE wintek_read_receipt (
  memo_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  read_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (memo_id, user_id),
  KEY idx_receipt_user (user_id),
  CONSTRAINT fk_receipt_memo FOREIGN KEY (memo_id) REFERENCES wintek_memo(id) ON DELETE CASCADE,
  CONSTRAINT fk_receipt_user FOREIGN KEY (user_id) REFERENCES wintek_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='읽음 확인';

-- =====================================================================
-- 8) 북마크  (사용자별)
-- =====================================================================
CREATE TABLE wintek_bookmark (
  memo_id    BIGINT NOT NULL,
  user_id    BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (memo_id, user_id),
  KEY idx_bookmark_user (user_id),
  CONSTRAINT fk_bookmark_memo FOREIGN KEY (memo_id) REFERENCES wintek_memo(id) ON DELETE CASCADE,
  CONSTRAINT fk_bookmark_user FOREIGN KEY (user_id) REFERENCES wintek_user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='북마크';

-- =====================================================================
-- 9) 알림  (type: urgent / comment / mention / status)
-- =====================================================================
CREATE TABLE wintek_notification (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  recipient_id BIGINT       NOT NULL                 COMMENT '받는 사람',
  type         ENUM('urgent','comment','mention','status') NOT NULL,
  title        VARCHAR(200) NOT NULL,
  content      VARCHAR(500) NULL,
  memo_id      BIGINT       NULL                      COMMENT '딥링크 대상 메모',
  is_read      TINYINT(1)   NOT NULL DEFAULT 0,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_noti_recipient (recipient_id, is_read),
  KEY idx_noti_created (created_at),
  CONSTRAINT fk_noti_recipient FOREIGN KEY (recipient_id) REFERENCES wintek_user(id),
  CONSTRAINT fk_noti_memo      FOREIGN KEY (memo_id)      REFERENCES wintek_memo(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='알림';

-- =====================================================================
-- 10) 디바이스  (FCM 푸시 토큰)
-- =====================================================================
CREATE TABLE wintek_device (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  fcm_token  VARCHAR(255) NOT NULL,
  platform   ENUM('android','ios') NOT NULL,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_device_token (fcm_token),
  KEY idx_device_user (user_id),
  CONSTRAINT fk_device_user FOREIGN KEY (user_id) REFERENCES wintek_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='디바이스(FCM)';

-- =====================================================================
-- 11) 리프레시 토큰  (개발용 JWT 인증. 운영 인증 방식에 따라 대체 가능)
-- =====================================================================
CREATE TABLE wintek_refresh_token (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  token      VARCHAR(255) NOT NULL,
  expires_at DATETIME     NOT NULL,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_refresh_token (token),
  KEY idx_refresh_user (user_id),
  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES wintek_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리프레시 토큰';

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  개발용 샘플 시드 (선택) — 운영 반영 X
-- =====================================================================
-- INSERT INTO wintek_user (employee_no,name,dept,position,role,is_active)
--   VALUES ('20230001','김민준','XR개발실 3팀','팀장','manager',1),
--          ('20230002','이예지','사업 5실 3팀','주임연구원','employee',1),
--          ('20230003','신현지','XR개발실 3팀','주임연구원','employee',1);
-- INSERT INTO wintek_project (name, client_name)
--   VALUES ('XR 헤드셋 납품','EQUIP'), ('XR 콘텐츠 개발','XR-EDU'), ('방산 시뮬레이터','DEF-SIM');
