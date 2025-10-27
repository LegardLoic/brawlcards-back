import { Prisma, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();
type SeedAbility = { abilityId: number; params?: Prisma.JsonValue };

async function main() {
  // --- reset minimal pour être déterministe en dev (OK car BDD locale)
  await prisma.$transaction([
    prisma.action.deleteMany(),
    prisma.gameEvent.deleteMany(),
    prisma.modifier.deleteMany(),
    prisma.triggerState.deleteMany(),
    prisma.playerCard.deleteMany(),
    prisma.player.deleteMany(),
    prisma.game.deleteMany(),
    prisma.cardAbility.deleteMany(),
    prisma.cardKeyword.deleteMany(),
    prisma.ability.deleteMany(),
    prisma.keyword.deleteMany(),
    prisma.card.deleteMany(),
    prisma.cardFamily.deleteMany(),
    prisma.user.deleteMany(),
  ]);

  // --- Statique : familles, keywords, abilities, cards
  const [crocNoir, fees] = await prisma.$transaction([
    prisma.cardFamily.create({ data: { name: "Croc-Noir", description: "Marins & terrestres — bivalence." }}),
    prisma.cardFamily.create({ data: { name: "Fées", description: "Tricks, buffs temporaires et auras." }}),
  ]);

  const keywords = await prisma.keyword.createMany({
    data: [
      { code: "TAUNT",   label: "Provocation" },
      { code: "SHIELD",  label: "Bouclier divin" },
      { code: "WINDFURY",label: "Double attaque" },
      { code: "DEATHRATTLE", label: "Râle d’agonie" },
      { code: "AURA",    label: "Aura" },
    ],
  });

  // récup pour joindre par code facilement
  const kw = Object.fromEntries(
    (await prisma.keyword.findMany()).map(k => [k.code, k])
  );

  // Abilities génériques (statique)
  const [abStartBuffAllies, abDeathSummonToken, abOnBuyBuffSelf, abAuraAllies] =
    await prisma.$transaction([
      prisma.ability.create({
        data: {
          name: "Coup d’Envol",
          trigger: "ON_START_COMBAT",
          targetSpec: { selector: "ALLIES", count: "ALL" },
          effectSpec: { addAtk: 1, addHp: 1, duration: "PERM" },
        },
      }),
      prisma.ability.create({
        data: {
          name: "Dernier Souffle",
          trigger: "ON_DEATH",
          targetSpec: { selector: "BOARD_SELF", count: 1, type: "SUMMON" },
          effectSpec: { summonCardName: "Croc-Noir — Recrue", atk: 2, hp: 1 },
        },
      }),
      prisma.ability.create({
        data: {
          name: "Affûtage",
          trigger: "ON_BUY",
          targetSpec: { selector: "SELF" },
          effectSpec: { addAtk: 2, addHp: 0, duration: "PERM" },
        },
      }),
      prisma.ability.create({
        data: {
          name: "Poussière de Fée",
          trigger: "PASSIVE",
          targetSpec: { selector: "ALLIES", condition: "ZONE=BOARD" },
          effectSpec: { addAtk: 1, addHp: 0, duration: "AURA" },
        },
      }),
    ]);

  // Cartes (statique)
  const cardsData = [
    {
      familyId: crocNoir.id,
      name: "Croc-Noir — Matelot",
      description: "Simple combattant.",
      atkBase: 2, hpBase: 2, tavernTier: 1,
      keywords: [],
      abilities: [],
    },
    {
      familyId: crocNoir.id,
      name: "Croc-Noir — Recrue",
      description: "Petit token invoqué.",
      atkBase: 2, hpBase: 1, tavernTier: 1,
      keywords: [],
      abilities: [],
    },
    {
      familyId: crocNoir.id,
      name: "Croc-Noir — Moussaillon vaillant",
      description: "Gagne +2 ATK quand acheté.",
      atkBase: 3, hpBase: 2, tavernTier: 2,
      keywords: [],
      abilities: [{ abilityId: abOnBuyBuffSelf.id }],
    },
    {
      familyId: crocNoir.id,
      name: "Croc-Noir — Porte-bouclier",
      description: "Provocation + Bouclier divin.",
      atkBase: 2, hpBase: 3, tavernTier: 2,
      keywords: [kw.TAUNT.id, kw.SHIELD.id],
      abilities: [],
    },
    {
      familyId: fees.id,
      name: "Fée Lumineuse",
      description: "Aura: +1 ATK pour les alliés.",
      atkBase: 2, hpBase: 2, tavernTier: 2,
      keywords: [kw.AURA.id],
      abilities: [{ abilityId: abAuraAllies.id }],
    },
    {
      familyId: fees.id,
      name: "Fée Dévouée",
      description: "Au début du combat, +1/+1 à tous les alliés.",
      atkBase: 1, hpBase: 3, tavernTier: 1,
      keywords: [],
      abilities: [{ abilityId: abStartBuffAllies.id }],
    },
    {
      familyId: crocNoir.id,
      name: "Croc-Noir — Baroudeur",
      description: "Râle d’agonie : invoque une Recrue.",
      atkBase: 3, hpBase: 1, tavernTier: 2,
      keywords: [kw.DEATHRATTLE.id],
      abilities: [{ abilityId: abDeathSummonToken.id }],
    },
  ];

  // insertion cartes + liaisons (keywords / abilities)
  for (const c of cardsData) {
    const card = await prisma.card.create({
      data: {
        familyId: c.familyId,
        name: c.name,
        description: c.description,
        atkBase: c.atkBase,
        hpBase: c.hpBase,
        tavernTier: c.tavernTier,
      },
    });

    if (c.keywords?.length) {
      await prisma.cardKeyword.createMany({
        data: c.keywords.map(kid => ({ cardId: card.id, keywordId: kid })),
        skipDuplicates: true,
      });
    }

    if (c.abilities?.length) {
      await prisma.cardAbility.createMany({
        data: c.abilities.map(a => ({
          cardId: card.id,
          abilityId: a.abilityId,
        })),
        skipDuplicates: true,
      });
    }
  }

  // --- Données de test (facultatif mais pratique) : 2 users, 1 game, 2 players, shop
  const [u1, u2] = await prisma.$transaction([
    prisma.user.create({ data: { email: "lohan@example.com", pseudo: "Lohan", passwordHash: "dev" }}),
    prisma.user.create({ data: { email: "ia@example.com", pseudo: "IA", passwordHash: "dev" }}),
  ]);

  const game = await prisma.game.create({
    data: { status: "WAITING", phase: "SHOP", rngSeed: "seed-001" },
  });

  const [p1, p2] = await prisma.$transaction([
    prisma.player.create({ data: { userId: u1.id, gameId: game.id, hp: 40, gold: 3, tavernLevel: 1, order: 0 }}),
    prisma.player.create({ data: { userId: u2.id, gameId: game.id, hp: 40, gold: 3, tavernLevel: 1, order: 1 }}),
  ]);

  // Récupère quelques cartes pour le SHOP
  const allCards = await prisma.card.findMany({
    where: { tavernTier: { lte: 2 } },
    orderBy: { id: "asc" },
    take: 6,
  });

  // 3 cartes shop pour chaque joueur
  await prisma.$transaction([
    ...allCards.slice(0, 3).map((c, i) =>
      prisma.playerCard.create({
        data: {
          playerId: p1.id,
          cardId: c.id,
          zone: "SHOP",
          position: i,
          atk: c.atkBase,
          hp: c.hpBase,
        },
      })
    ),
    ...allCards.slice(3, 6).map((c, i) =>
      prisma.playerCard.create({
        data: {
          playerId: p2.id,
          cardId: c.id,
          zone: "SHOP",
          position: i,
          atk: c.atkBase,
          hp: c.hpBase,
        },
      })
    ),
  ]);

  console.log("✅ Seed terminée : familles, keywords, abilities, cartes, game de test.");
}

main()
  .catch((e) => {
    console.error("❌ Seed error:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
