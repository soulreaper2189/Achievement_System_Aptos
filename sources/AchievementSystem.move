module Likhith::AchievementSystem {
    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::timestamp;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;

    /// Struct representing player achievements
    struct PlayerAchievements has store, key {
        achievement_ids: vector<u64>,     // List of unlocked achievement IDs
        total_score: u64,                 // Player's cumulative score
        nft_count: u64,                   // Number of NFT rewards earned
        achievement_events: EventHandle<AchievementUnlocked>,
    }

    /// Event emitted when an achievement is unlocked
    struct AchievementUnlocked has drop, store {
        player: address,
        achievement_id: u64,
        timestamp: u64,
    }

    /// Function to initialize a player's achievement record
    public fun initialize_player(player: &signer) {
        let achievements = PlayerAchievements {
            achievement_ids: vector::empty<u64>(),
            total_score: 0,
            nft_count: 0,
            achievement_events: account::new_event_handle<AchievementUnlocked>(player),
        };
        move_to(player, achievements);
    }

    /// Function to unlock an achievement and mint NFT reward
    public fun unlock_achievement(
        player: &signer, 
        achievement_id: u64, 
        score_earned: u64
    ) acquires PlayerAchievements {
        let player_addr = signer::address_of(player);
        let achievements = borrow_global_mut<PlayerAchievements>(player_addr);
        
        // Check if achievement already unlocked
        if (!vector::contains(&achievements.achievement_ids, &achievement_id)) {
            // Add new achievement
            vector::push_back(&mut achievements.achievement_ids, achievement_id);
            achievements.total_score = achievements.total_score + score_earned;
            achievements.nft_count = achievements.nft_count + 1;
            
            // Emit achievement unlocked event (simulates NFT minting)
            event::emit_event(&mut achievements.achievement_events, AchievementUnlocked {
                player: player_addr,
                achievement_id,
                timestamp: timestamp::now_seconds(),
            });
        };
    }
}