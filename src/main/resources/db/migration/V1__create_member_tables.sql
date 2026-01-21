CREATE TABLE members (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT,
    email               VARCHAR(255) UNIQUE NOT NULL,
    password_hash       VARCHAR(255) NOT NULL,
    username            VARCHAR(50) NOT NULL,
    phone               VARCHAR(20),
    avatar_url          VARCHAR(500),
    role                ENUM('BUYER', 'SELLER', 'ADMIN') NOT NULL DEFAULT 'BUYER',
    status              ENUM('ACTIVE', 'SUSPEND', 'DELETED') NOT NULL DEFAULT 'ACTIVE',
    login_failed_count  INT DEFAULT 0,
    last_login_at       TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX               idx_email (email),
    INDEX               idx_role (role),
    INDEX               idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE addresses
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id       BIGINT NOT NULL,
    receiver_name   VARCHAR(50) NOT NULL,
    receiver_phone  VARCHAR(20) NOT NULL,
    province        VARCHAR(50) NOT NULL,
    city            VARCHAR(50) NOT NULL,
    district        VARCHAR(50) NOT NULL,
    detail_address  VARCHAR(255) NOT NULL,
    postal_code     VARCHAR(10) NOT NULL,
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    INDEX           idx_member_id (member_id),
    INDEX           idx_is_default (member_id, is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE refresh_tokens
(
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id    BIGINT    NOT NULL,
    token_hash   VARCHAR(500),
    device_info  VARCHAR(200),
    ip_address   VARCHAR(45),
    expires_at   TIMESTAMP NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP NULL,

    UNIQUE KEY uk_token_hash(token_hash),
    INDEX        idx_member_id(member_id),
    INDEX        idx_expires_at(expires_at),

    FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;