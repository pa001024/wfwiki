--Database for Module:Arcane --
--go away error messages
--based on M:Focus/Data, which was based on M:Mods/Data
--Sorted first by Arcane types, then alphabetically
--

local ArcaneData = {
["Arcanes"] = {
--
--
--Arcanes
--
--
	["Arcane Acceleration"] = {
		Icon = "ArcaneAcceleration64x.png",
		Image = "ArcaneAcceleration.png",
		Name = "Arcane Acceleration",
		Desc4 = "20% chance for +60% Fire Rate to Rifles for 6s",
		Criteria ="On Critical Hit",
	},
	["Arcane Aegis"] = {
		Icon = "ArcaneAegis64x.png",
		Image = "ArcaneAegis.png",
		Name = "Arcane Aegis",
		Desc4 = "6% chance for +60 Shields Per Second for 20s",
		Criteria ="On Damaged",
	},
	["Arcane Agility"] = {
		Icon = "ArcaneAegis64x.png",
		Image = "ArcaneAgility.png",
		Name = "Arcane Agility",
		Desc4 = "16% chance for +40% Speed for 8s",
		Criteria ="On Damaged",
	},
	["Arcane Arachne"] = {
		Icon = "ArcaneArachne64x.png",
		Image = "ArcaneArachne.png",
		Name = "Arcane Arachne",
		Desc4 = "60% chance for 100% bonus damage on next hit",
		Criteria ="On Wall Latch",
	},
	["Arcane Avenger"] = {
		Icon = "ArcaneAvenger64x.png",
		Image = "ArcaneAvenger.png",
		Name = "Arcane Avenger",
		Desc4 = "14% chance for +30% Critical Chance for 8s",
		Criteria ="On Damaged",
	},
	["Arcane Awakening"] = {
		Icon = "ArcaneAwakening64x.png",
		Image = "ArcaneAwakening.png",
		Name = "Arcane Awakening",
		Desc4 = "40% chance for +100% Damage to Pistols for 16s",
		Criteria ="On Reload",
	},
	["Arcane Barrier"] = {
		Icon = "ArcaneBarrier64x.png",
		Image = "ArcaneBarrier.png",
		Name = "Arcane Barrier",
		Desc4 = "4% chance to instanly restore all shields",
		Criteria ="On Damaged",
	},
	["Arcane Consequence"] = {
		Icon = "ArcaneConsequence64x.png",
		Image = "ArcaneConsequence.png",
		Name = "Arcane Consequence",
		Desc4 = "100% chance for +40% Bullet Jump for 12s",
		Criteria ="On Headshot",
	},
	["Arcane Deflection"] = {
		Icon = "ArcaneDeflection64x.png",
		Image = "ArcaneDeflection.png",
		Name = "Arcane Deflection",
		Desc4 = "+80% chance to resist a Slash damage effect",
		Criteria ="Passive",
	},
	["Arcane Energize"] = {
		Icon = "ArcaneEnergize64x.png",
		Image = "ArcaneEnergize.png",
		Name = "Arcane Energize",
		Desc4 = "40% chance to replenish energy to nearby allies",
		Criteria ="On Energy Pickup",
	},
	["Arcane Eruption"] = {
		Icon = "ArcaneEruption64x.png",
		Image = "ArcaneEruption.png",
		Name = "Arcane Eruption",
		Desc4 = "20% chance to knockdown nearby enemies",
		Criteria ="On Energy Pickup",
	},
	["Arcane Fury"] = {
		Icon = "ArcaneFury64x.png",
		Image = "ArcaneFury.png",
		Name = "Arcane Fury",
		Desc4 = "40% chance for +120% Melee Damage to Melee Weapons for 12s",
		Criteria ="On Critical Hit",
	},
	["Arcane Grace"] = {
		Icon = "ArcaneGrace64x.png",
		Image = "ArcaneGrace.png",
		Name = "Arcane Grace",
		Desc4 = "6% chance for +4% Health Regeneration Per Second for 6s",
		Criteria ="On Damaged",
	},
	["Arcane Guardian"] = {
		Icon = "ArcaneGuardian64x.png",
		Image = "ArcaneGuardian.png",
		Name = "Arcane Guardian",
		Desc4 = "20% chance for +600 Armor for 20s",
		Criteria ="On Damaged",
	},
	["Arcane Healing"] = {
		Icon = "ArcaneHealing64x.png",
		Image = "ArcaneHealing.png",
		Name = "Arcane Healing",
		Desc4 = "+80% chance to resist a Radiation damage effect",
		Criteria ="Passive",
	},
	["Arcane Ice"] = {
		Icon = "ArcaneIce64x.png",
		Image = "ArcaneIce.png",
		Name = "Arcane Ice",
		Desc4 = "+80% chance to resist a Heat damage effect",
		Criteria ="Passive",
	},
	["Arcane Momentum"] = {
		Icon = "ArcaneMomentum64x.png",
		Image = "ArcaneMomentum.png",
		Name = "Arcane Momentum",
		Desc4 = "40% chance for +100% Reload Speed to Sniper Rifles for 8s",
		Criteria ="On Critical Hit",
	},
	["Arcane Nullifier"] = {
		Icon = "ArcaneNullifier64x.png",
		Image = "ArcaneNullifier.png",
		Name = "Arcane Nullifier",
		Desc4 = "+80% chance to resist a Magnetic damage effect",
		Criteria ="Passive",
	},
	["Arcane Phantasm"] = {
		Icon = "ArcanePhantasm64x.png",
		Image = "ArcanePhantasm.png",
		Name = "Arcane Phantasm",
		Desc4 = "32% chance for +40% Speed for 12s",
		Criteria ="On Parry",
	},
	["Arcane Precision"] = {
		Icon = "ArcanePrecision64x.png",
		Image = "ArcanePrecision.png",
		Name = "Arcane Precision",
		Desc4 = "80% chance for +120% Damage to Pistols for 8s",
		Criteria ="On Headshot",
	},
	["Arcane Pulse"] = {
		Icon = "ArcanePulse64x.png",
		Image = "ArcanePulse.png",
		Name = "Arcane Pulse",
		Desc4 = "20% chance to heal nearby allies",
		Criteria ="On Health Pickup",
	},
	["Arcane Rage"] = {
		Icon = "ArcaneRage64x.png",
		Image = "ArcaneRage.png",
		Name = "Arcane Rage",
		Desc4 = "10% chance for +120% Damage to Rifles for 16s",
		Criteria ="On Headshot",
	},
	["Arcane Resistance"] = {
		Icon = "ArcaneResistance64x.png",
		Image = "ArcaneResistance.png",
		Name = "Arcane Resistance",
		Desc4 = "+80% chance to resist a Toxin damage effect",
		Criteria ="Passive",
	},
	["Arcane Strike"] = {
		Icon = "ArcaneStrike64x.png",
		Image = "ArcaneStrike.png",
		Name = "Arcane Strike",
		Desc4 = "10% chance for +40% Attack Speed to Melee Weapons for 12s",
		Criteria ="On Hit",
	},
	["Arcane Tempo"] = {
		Icon = "ArcaneTempo64x.png",
		Image = "ArcaneTempo.png",
		Name = "Arcane Tempo",
		Desc4 = "10% chance for +60% Fire Rate to Shotguns for 8s",
		Criteria ="On Critical Hit",
	},
	["Arcane Trickery"] = {
		Icon = "ArcaneTrickery64x.png",
		Image = "ArcaneTrickery.png",
		Name = "Arcane Trickery",
		Desc4 = "10% chance to become invisible for 20s",
		Criteria ="On Finisher",
	},
	["Arcane Ultimatum"] = {
		Icon = "ArcaneUltimatum64x.png",
		Image = "ArcaneUltimatum.png",
		Name = "Arcane Ultimatum",
		Desc4 = "100% chance for +600 Armor for 20s",
		Criteria ="On Finisher",
	},
	["Arcane Velocity"] = {
		Icon = "ArcaneVelocity64x.png",
		Image = "ArcaneVelocity.png",
		Name = "Arcane Velocity",
		Desc4 = "60% chance for +80% Fire Rate to Pistols for 6s",
		Criteria ="On Critical Hit",
	},
	["Arcane Victory"] = {
		Icon = "ArcaneVictory64x.png",
		Image = "ArcaneVictory.png",
		Name = "Arcane Victory",
		Desc4 = "8% chance for +2.0% Health Regeneration Per Second for 8s",
		Criteria ="On Headshot",
	},
	["Arcane Warmth"] = {
		Icon = "ArcaneWarmth64x.png",
		Image = "ArcaneWarmth.png",
		Name = "Arcane Warmth",
		Desc4 = "+80% chance to resist a Cold damage effect",
		Criteria ="Passive",
	},
--
--
--Exodia
--
--
	["Exodia Brave"] = {
		Icon = "ExodiaBrave64x.png",
		Image = "ExodiaBrave.png",
		Name = "Exodia Brave",
		Desc4 = "+5.00 Energy Regen for 4s",
		Criteria ="On Channel Kill",
	},
	["Exodia Contagion"] = {
		Icon = "ExodiaContagion64x.png",
		Image = "ExodiaContagion.png",
		Name = "Exodia Contagion",
		Desc4 = "Air melee launches a projectile that explodes on impact, increasing damage dealt by 400% damage after traveling 30m",
		Criteria ="After a Bullet Jump or Double Jump",
	},
	["Exodia Epidemic"] = {
		Icon = "ExodiaEpidemic64x.png",
		Image = "ExodiaEpidemic.png",
		Name = "Exodia Epidemic",
		Desc4 = "Slam emits a shockwave forwards that suspends enemies in the air for 4 seconds",
		Criteria ="After a Bullet Jump or Double Jump",
	},
	["Exodia Force"] = {
		Icon = "ExodiaForce64x.png",
		Image = "ExodiaForce.png",
		Name = "Exodia Force",
		Desc4 = "50% chance for 6m Radial Blast for 200% Weapon Damage",
		Criteria ="On Status Effect",
	},
	["Exodia Hunt"] = {
		Icon = "ExodiaHunt64x.png",
		Image = "ExodiaHunt.png",
		Name = "Exodia Hunt",
		Desc4 = "50% chance to pull in nearby enemies within 12m",
		Criteria ="On Slam Attack",
	},
	["Exodia Might"] = {
		Icon = "ExodiaMight64x.png",
		Image = "ExodiaMight.png",
		Name = "Exodia Might",
		Desc4 = "50% chance for +30% Lifesteal for 8s",
		Criteria ="On Finisher",
	},
	["Exodia Triumph"] = {
		Icon = "ExodiaTriumph64x.png",
		Image = "ExodiaTriumph.png",
		Name = "Exodia Triumph",
		Desc4 = "20% chance for +200% Channeling Damage for 12s",
		Criteria ="On Status Effect",
	},
	["Exodia Valor"] = {
		Icon = "ExodiaValor64x.png",
		Image = "ExodiaValor.png",
		Name = "Exodia Valor",
		Desc4 = "20% chance for +200% Channeling Damage for 12s",
		Criteria ="On Critical Hit",
	},
--
--
--Magus
--
--
    ["Magus Accelerant"] = {
		Icon = "MagusAccelerant64x.png",
		Image = "MagusAccelerant.png",
		Name = "Magus Accelerant",
		Desc4 = "Reduce Enemy Resistance to Heat Damage by 50%.",
		Criteria ="On Void Blast",
	},
    ["Magus Anomaly"] = {
		Icon = "MagusAnomaly64x.png",
		Image = "MagusAnomaly.png",
		Name = "Magus Anomaly",
		Desc4 = "Enemies within 20m are pulled towards Warframe.",
		Criteria ="On Transference In",
	},
	["Magus Cadence"] = {
		Icon = "MagusCadence64x.png",
		Image = "MagusCadence.png",
		Name = "Magus Cadence",
		Desc4 = "100% chance for +60% Sprint Speed for 8s",
		Criteria ="On Void Dash",
	},
	["Magus Cloud"] = {
		Icon = "MagusCloud64x.png",
		Image = "MagusCloud.png",
		Name = "Magus Cloud",
		Desc4 = "100% chance for Immunity to Falling Damage for 8s",
		Criteria ="On Void Dash",
	},
	["Magus Destruct"] = {
		Icon = "MagusDestruct64x.png",
		Image = "MagusDestruct.png",
		Name = "Magus Destruct",
		Desc4 = "Reduce Enemy Resistance to Puncture Damage by 50%.",
		Criteria ="On Void Blast",
	},
	["Magus Drive"] = {
		Icon = "MagusDrive64x.png",
		Image = "MagusDrive.png",
		Name = "Magus Drive",
		Desc4 = "Increase K-Drive Speed by 100% for 20s.",
		Criteria ="On Transference In",
	},
	["Magus Elevate"] = {
		Icon = "MagusElevate64x.png",
		Image = "MagusElevate.png",
		Name = "Magus Elevate",
		Desc4 = "75% chance to Heal Warframe for 200",
		Criteria ="On Enter Warframe",
	},
	["Magus Firewall"] = {
		Icon = "MagusFirewall64x.png",
		Image = "MagusFirewall.png",
		Name = "Magus Firewall",
		Desc4 = "Generate Void Particles every 3s up to 6 particles, each granting 12.5% Damage Reduction for 40s. Taking damage damage consumes a particle.",
		Criteria ="On Void Mode",
	},
	["Magus Glitch"] = {
		Icon = "MagusGlitch64x.png",
		Image = "MagusGlitch.png",
		Name = "Magus Glitch",
		Desc4 = "100% chance to negate Transference Static",
		Criteria ="On Transference Static",
	},
	["Magus Husk"] = {
		Icon = "MagusHusk64x.png",
		Image = "MagusHusk.png",
		Name = "Magus Husk",
		Desc4 = "+100 Armor to Operator",
		Criteria ="Passive",
	},
	["Magus Lockdown"] = {
		Icon = "MagusLockdown64x.png",
		Image = "MagusLockdown.png",
		Name = "Magus Lockdown",
		Desc4 = "Drop a Tether Mine at destination that tethers up to 8 enemies within 12m. The tether mine explodes dealing 60% of their Health as Puncture Damage after 4s.",
		Criteria ="On Void Dash",
	},
	["Magus Melt"] = {
		Icon = "MagusMelt64x.png",
		Image = "MagusMelt.png",
		Name = "Magus Melt",
		Desc4 = "Increase Heat Damage in Operator Mode by 20% for 10s, stacking up to 5x",
		Criteria ="On Void Dash",
	},
	["Magus Nourish"] = {
		Icon = "MagusNourish64x.png",
		Image = "MagusNourish.png",
		Name = "Magus Nourish",
		Desc4 = "Heal Warframe by 25 per second",
		Criteria ="On Exit Warframe",
	},
	["Magus Overload"] = {
		Icon = "MagusOverload64x.png",
		Image = "MagusOverload.png",
		Name = "Magus Overload",
		Desc4 = "Stun Robotic enemies for 3s, which then discharge Electricity Damage dealing 60% of their Max Health to anyone within 20m",
		Criteria ="On Void Blast",
	},
	["Magus Repair"] = {
		Icon = "MagusRepair64x.png",
		Image = "MagusRepair.png",
		Name = "Magus Repair",
		Desc4 = "Heal Warframes within 20m by 10% Health/s",
		Criteria ="On Void Mode",
	},
	["Magus Replenish"] = {
		Icon = "MagusReplenish64x.png",
		Image = "MagusReplenish.png",
		Name = "Magus Replenish",
		Desc4 = "100% chance to heal for 20% health",
		Criteria ="On Void Dash",
	},
	["Magus Revert"] = {
		Icon = "MagusRevert64x.png",
		Image = "MagusRevert.png",
		Name = "Magus Revert",
		Desc4 = "Void Dash can be used again within 3s, costing no Energy and taking the Operator back to the location where they had started their Void Dash. Restores 40 Health.",
		Criteria ="On Void Dash",
	},
	["Magus Vigor"] = {
		Icon = "MagusVigor64x.png",
		Image = "MagusVigor.png",
		Name = "Magus Vigor",
		Desc4 = "+200 Health to Operator",
		Criteria ="Passive",
	},
--
--
--Pax
--
--
	["Pax Bolt"] = {
		Icon = "PaxBolt64x.png",
		Image = "PaxBolt.png",
		Name = "Pax Bolt",
		Desc4 = "50% Chance for +30% Strength and Efficiency for 4s",
		Criteria ="On Headshot",
	},

	["Pax Charge"] = {
		Icon = "PaxCharge64x.png",
		Image = "PaxCharge.png",
		Name = "Pax Charge",
		Desc4 = "Converts weapon magazine to rechargable",
		Criteria ="Passive",
	},

	["Pax Seeker"] = {
		Icon = "PaxSeeker64x.png",
		Image = "PaxSeeker.png",
		Name = "Pax Seeker",
		Desc4 = "100% Chance to release 4 homing projectiles",
		Criteria ="On Headshot",
	},

	["Pax Soar"] = {
		Icon = "PaxSoar64x.png",
		Image = "PaxSoar.png",
		Name = "Pax Soar",
		Desc4 = "+60% Accuracy, -60% Recoil and +5s Wall Latch",
		Criteria ="While Airborne",
	},
--
--
--Virtuos
--
--
	["Virtuos Forge"] = {
	    Icon = "VirtuosForge64x.png",
		Image = "VirtuosForge.png",
		Name = "Virtuos Forge",
		Desc4 = "Converts 100% Void Damage to Heat Damage.",
		Criteria ="On Hit",
	},

	["Virtuos Fury"] = {
		Icon = "VirtuosFury64x.png",
		Image = "VirtuosFury.png",
		Name = "Virtuos Fury",
		Desc4 = "20% chance for +30% Damage for 4s",
		Criteria ="On Status Effect",
	},

	["Virtuos Ghost"] = {
		Icon = "VirtuosGhost64x.png",
		Image = "VirtuosGhost.png",
		Name = "Virtuos Ghost",
		Desc4 = "40% chance for +60% Status Chance for 12s",
		Criteria ="On Headshot",
	},

	["Virtuos Null"] = {
		Icon = "VirtuosNull64x.png",
		Image = "VirtuosNull.png",
		Name = "Virtuos Null",
		Desc4 = "+20% Amp Energy Regen for 4s",
		Criteria ="On Kill",
	},

	["Virtuos Shadow"] = {
		Icon = "VirtuosShadow64x.png",
		Image = "VirtuosShadow.png",
		Name = "Virtuos Shadow",
		Desc4 = "40% chance for +60% Critical Chance for 12s",
		Criteria ="On Headshot",
	},

	["Virtuos Spike"] = {
	    Icon = "VirtuosSpike64x.png",
		Image = "VirtuosSpike.png",
		Name = "Virtuos Spike",
		Desc4 = "Converts 100% Void Damage to Puncture Damage.",
		Criteria ="On Hit",
	},

	["Virtuos Strike"] = {
		Icon = "VirtuosStrike64x.png",
		Image = "VirtuosStrike.png",
		Name = "Virtuos Strike",
		Desc4 = "20% chance for +60% Critical Damage for 4s",
		Criteria ="On Critical Hit",
	},

	["Virtuos Surge"] = {
	    Icon = "VirtuosSurge64x.png",
		Image = "VirtuosSurge.png",
		Name = "Virtuos Surge",
		Desc4 = "Converts 100% Void Damage to Electricity Damage.",
		Criteria ="On Hit",
	},

	["Virtuos Tempo"] = {
		Icon = "VirtuosTempo64x.png",
		Image = "VirtuosTempo.png",
		Name = "Virtuos Tempo",
		Desc4 = "60% chance for +60% Fire Rate for 8s",
		Criteria ="On Kill",
	},

	["Virtuos Trojan"] = {
	    Icon = "VirtuosTrojan64x.png",
		Image = "VirtuosTrojan.png",
		Name = "Virtuos Trojan",
		Desc4 = "Converts 100% Void Damage to Viral Damage.",
		Criteria ="On Hit",
	},
}
}
 
return ArcaneData
