-- CreateEnum
CREATE TYPE "GameStatus" AS ENUM ('WAITING', 'IN_PROGRESS', 'FINISHED', 'CANCELED');

-- CreateEnum
CREATE TYPE "Phase" AS ENUM ('SHOP', 'COMBAT');

-- CreateEnum
CREATE TYPE "Zone" AS ENUM ('SHOP', 'HAND', 'BOARD', 'GRAVEYARD', 'DECK');

-- CreateEnum
CREATE TYPE "AbilityTrigger" AS ENUM ('ON_BUY', 'ON_SELL', 'ON_SUMMON', 'ON_START_COMBAT', 'ON_DEATH', 'ON_DAMAGE', 'ON_ATTACK', 'ON_PLAY', 'PASSIVE');

-- CreateEnum
CREATE TYPE "ModifierScope" AS ENUM ('SELF', 'BOARD_ALLY', 'BOARD_ENEMY', 'GLOBAL');

-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "pseudo" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Game" (
    "id" SERIAL NOT NULL,
    "status" "GameStatus" NOT NULL DEFAULT 'WAITING',
    "turn" INTEGER NOT NULL DEFAULT 1,
    "phase" "Phase" NOT NULL DEFAULT 'SHOP',
    "rngSeed" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Game_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Player" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "gameId" INTEGER NOT NULL,
    "hp" INTEGER NOT NULL DEFAULT 40,
    "gold" INTEGER NOT NULL DEFAULT 0,
    "tavernLevel" INTEGER NOT NULL DEFAULT 1,
    "order" INTEGER NOT NULL DEFAULT 0,
    "ready" BOOLEAN NOT NULL DEFAULT false,
    "socketId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CardFamily" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "CardFamily_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Card" (
    "id" SERIAL NOT NULL,
    "familyId" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "atkBase" INTEGER NOT NULL DEFAULT 0,
    "hpBase" INTEGER NOT NULL DEFAULT 1,
    "tavernTier" INTEGER NOT NULL DEFAULT 1,
    "rarity" TEXT,
    "img" TEXT,

    CONSTRAINT "Card_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Keyword" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "label" TEXT,

    CONSTRAINT "Keyword_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CardKeyword" (
    "cardId" INTEGER NOT NULL,
    "keywordId" INTEGER NOT NULL,

    CONSTRAINT "CardKeyword_pkey" PRIMARY KEY ("cardId","keywordId")
);

-- CreateTable
CREATE TABLE "Ability" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "trigger" "AbilityTrigger" NOT NULL,
    "targetSpec" JSONB,
    "effectSpec" JSONB,

    CONSTRAINT "Ability_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CardAbility" (
    "id" SERIAL NOT NULL,
    "cardId" INTEGER NOT NULL,
    "abilityId" INTEGER NOT NULL,
    "params" JSONB,

    CONSTRAINT "CardAbility_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlayerCard" (
    "id" SERIAL NOT NULL,
    "playerId" INTEGER NOT NULL,
    "cardId" INTEGER NOT NULL,
    "zone" "Zone" NOT NULL,
    "position" INTEGER NOT NULL DEFAULT 0,
    "atk" INTEGER NOT NULL DEFAULT 0,
    "hp" INTEGER NOT NULL DEFAULT 1,
    "isGolden" BOOLEAN NOT NULL DEFAULT false,
    "exhausted" BOOLEAN NOT NULL DEFAULT false,
    "attacksLeft" INTEGER NOT NULL DEFAULT 1,
    "shield" BOOLEAN NOT NULL DEFAULT false,
    "stealth" BOOLEAN NOT NULL DEFAULT false,
    "taunt" BOOLEAN NOT NULL DEFAULT false,
    "poisonous" BOOLEAN NOT NULL DEFAULT false,
    "lifesteal" BOOLEAN NOT NULL DEFAULT false,
    "reborn" BOOLEAN NOT NULL DEFAULT false,
    "sourcePlayerCardId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlayerCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Modifier" (
    "id" SERIAL NOT NULL,
    "playerCardId" INTEGER,
    "playerId" INTEGER,
    "sourcePlayerCardId" INTEGER,
    "type" TEXT NOT NULL,
    "scope" "ModifierScope" NOT NULL DEFAULT 'SELF',
    "stacks" INTEGER NOT NULL DEFAULT 1,
    "uniqueKey" TEXT,
    "startTurn" INTEGER,
    "endTurn" INTEGER,
    "data" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Modifier_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TriggerState" (
    "id" SERIAL NOT NULL,
    "playerCardId" INTEGER NOT NULL,
    "abilityId" INTEGER NOT NULL,
    "lastTurnUsed" INTEGER,
    "chargesLeft" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TriggerState_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GameEvent" (
    "id" SERIAL NOT NULL,
    "gameId" INTEGER NOT NULL,
    "actorPlayerId" INTEGER,
    "type" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GameEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Action" (
    "id" SERIAL NOT NULL,
    "gameId" INTEGER NOT NULL,
    "playerId" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Action_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_pseudo_key" ON "User"("pseudo");

-- CreateIndex
CREATE INDEX "Game_status_idx" ON "Game"("status");

-- CreateIndex
CREATE INDEX "Game_phase_idx" ON "Game"("phase");

-- CreateIndex
CREATE INDEX "Player_gameId_idx" ON "Player"("gameId");

-- CreateIndex
CREATE INDEX "Player_userId_idx" ON "Player"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Player_gameId_userId_key" ON "Player"("gameId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "CardFamily_name_key" ON "CardFamily"("name");

-- CreateIndex
CREATE INDEX "Card_familyId_idx" ON "Card"("familyId");

-- CreateIndex
CREATE INDEX "Card_tavernTier_idx" ON "Card"("tavernTier");

-- CreateIndex
CREATE UNIQUE INDEX "Keyword_code_key" ON "Keyword"("code");

-- CreateIndex
CREATE INDEX "CardAbility_cardId_idx" ON "CardAbility"("cardId");

-- CreateIndex
CREATE INDEX "CardAbility_abilityId_idx" ON "CardAbility"("abilityId");

-- CreateIndex
CREATE UNIQUE INDEX "CardAbility_cardId_abilityId_key" ON "CardAbility"("cardId", "abilityId");

-- CreateIndex
CREATE INDEX "PlayerCard_playerId_zone_position_idx" ON "PlayerCard"("playerId", "zone", "position");

-- CreateIndex
CREATE INDEX "PlayerCard_cardId_idx" ON "PlayerCard"("cardId");

-- CreateIndex
CREATE INDEX "Modifier_playerCardId_idx" ON "Modifier"("playerCardId");

-- CreateIndex
CREATE INDEX "Modifier_playerId_idx" ON "Modifier"("playerId");

-- CreateIndex
CREATE INDEX "Modifier_uniqueKey_idx" ON "Modifier"("uniqueKey");

-- CreateIndex
CREATE INDEX "TriggerState_abilityId_idx" ON "TriggerState"("abilityId");

-- CreateIndex
CREATE UNIQUE INDEX "TriggerState_playerCardId_abilityId_key" ON "TriggerState"("playerCardId", "abilityId");

-- CreateIndex
CREATE INDEX "GameEvent_gameId_createdAt_idx" ON "GameEvent"("gameId", "createdAt");

-- CreateIndex
CREATE INDEX "GameEvent_actorPlayerId_idx" ON "GameEvent"("actorPlayerId");

-- CreateIndex
CREATE INDEX "Action_gameId_createdAt_idx" ON "Action"("gameId", "createdAt");

-- CreateIndex
CREATE INDEX "Action_playerId_createdAt_idx" ON "Action"("playerId", "createdAt");

-- AddForeignKey
ALTER TABLE "Player" ADD CONSTRAINT "Player_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Player" ADD CONSTRAINT "Player_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "Game"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Card" ADD CONSTRAINT "Card_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "CardFamily"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CardKeyword" ADD CONSTRAINT "CardKeyword_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CardKeyword" ADD CONSTRAINT "CardKeyword_keywordId_fkey" FOREIGN KEY ("keywordId") REFERENCES "Keyword"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CardAbility" ADD CONSTRAINT "CardAbility_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CardAbility" ADD CONSTRAINT "CardAbility_abilityId_fkey" FOREIGN KEY ("abilityId") REFERENCES "Ability"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerCard" ADD CONSTRAINT "PlayerCard_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerCard" ADD CONSTRAINT "PlayerCard_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerCard" ADD CONSTRAINT "PlayerCard_sourcePlayerCardId_fkey" FOREIGN KEY ("sourcePlayerCardId") REFERENCES "PlayerCard"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Modifier" ADD CONSTRAINT "Modifier_playerCardId_fkey" FOREIGN KEY ("playerCardId") REFERENCES "PlayerCard"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Modifier" ADD CONSTRAINT "Modifier_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Modifier" ADD CONSTRAINT "Modifier_sourcePlayerCardId_fkey" FOREIGN KEY ("sourcePlayerCardId") REFERENCES "PlayerCard"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TriggerState" ADD CONSTRAINT "TriggerState_playerCardId_fkey" FOREIGN KEY ("playerCardId") REFERENCES "PlayerCard"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TriggerState" ADD CONSTRAINT "TriggerState_abilityId_fkey" FOREIGN KEY ("abilityId") REFERENCES "Ability"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GameEvent" ADD CONSTRAINT "GameEvent_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "Game"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GameEvent" ADD CONSTRAINT "GameEvent_actorPlayerId_fkey" FOREIGN KEY ("actorPlayerId") REFERENCES "Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Action" ADD CONSTRAINT "Action_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "Game"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Action" ADD CONSTRAINT "Action_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;
