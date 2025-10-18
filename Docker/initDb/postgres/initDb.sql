-- v100----------------------------------------------------------------------------
CREATE TABLE TariffDraft (
    Id UUID PRIMARY KEY,
    Name VARCHAR(255),
    PerMinuteCost DECIMAL(18, 2),
    SmsCost DECIMAL(18, 2),
    ConnectionFee DECIMAL(18, 2),
    PerSecondBilling INT,
	ExternalIncomingCallPerSecondReward DECIMAL(18, 2),
	BonusForRechargeAmount DECIMAL(18, 2),
	BonusForRechargeValue DECIMAL(18, 2),
	BonusForRechargeExpiresIn BIGINT,
	ServiceBundleRecurringPrice DECIMAL(18, 2),
    ServiceBundleRecurringCallMinutesAmount INT,
    ServiceBundleRecurringSmsAmount INT,
	ServiceBundleRecurringExpiresIn BIGINT,
	ServiceBundleDailyPrice DECIMAL(18, 2),
    ServiceBundleDailyCallMinutesAmount INT,
    ServiceBundleDailySmsAmount INT
);

CREATE TABLE Tariff (
    Id UUID PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PerMinuteCost DECIMAL(18, 2) NOT NULL,
    SmsCost DECIMAL(18, 2) NOT NULL,
    ConnectionFee DECIMAL(18, 2) NOT NULL,
    PerSecondBilling INT NOT NULL,
	ExternalIncomingCallPerSecondReward DECIMAL(18, 2),
	BonusForRechargeAmount DECIMAL(18, 2),
	BonusForRechargeValue DECIMAL(18, 2),
	BonusForRechargeExpiresIn BIGINT,
	ServiceBundleRecurringPrice DECIMAL(18, 2),
    ServiceBundleRecurringCallMinutesAmount INT,
    ServiceBundleRecurringSmsAmount INT,
	ServiceBundleRecurringExpiresIn BIGINT,
	ServiceBundleDailyPrice DECIMAL(18, 2),
    ServiceBundleDailyCallMinutesAmount INT,
    ServiceBundleDailySmsAmount INT,
    Status INT NOT NULL
);

CREATE TABLE TariffUpdated (
    Id UUID PRIMARY KEY,
    TariffId UUID NOT NULL,
    Name VARCHAR(255) NOT NULL,
    PerMinuteCost DECIMAL(18, 2) NOT NULL,
    SmsCost DECIMAL(18, 2) NOT NULL,
    ConnectionFee DECIMAL(18, 2) NOT NULL,
    PerSecondBilling INT NOT NULL,
	ExternalIncomingCallPerSecondReward DECIMAL(18, 2),
	BonusForRechargeAmount DECIMAL(18, 2),
	BonusForRechargeValue DECIMAL(18, 2),
	BonusForRechargeExpiresIn BIGINT,
	ServiceBundleRecurringPrice DECIMAL(18, 2),
    ServiceBundleRecurringCallMinutesAmount INT,
    ServiceBundleRecurringSmsAmount INT,
	ServiceBundleRecurringExpiresIn BIGINT,
	ServiceBundleDailyPrice DECIMAL(18, 2),
    ServiceBundleDailyCallMinutesAmount INT,
    ServiceBundleDailySmsAmount INT,
    Status INT NOT NULL,
    UpdateDate TIMESTAMP NOT NULL,
    HandledDate TIMESTAMP
);

CREATE TABLE StreamPosition
(
    ServiceName VARCHAR(255) NOT NULL PRIMARY KEY,
    CommitPosition BIGINT NOT NULL,
    PreparePosition BIGINT NOT NULL
);

CREATE TABLE SimCardSummary (
    Number TEXT PRIMARY KEY,
    Id UUID NOT NULL
);