module Likhith::AchievementSystem {
    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::timestamp;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;

    
    struct PlayerAchievements has store, key {
        achievement_ids: vector<u64>,     
        total_score: u64,                 
        nft_count: u64,                   
        achievement_events: EventHandle<AchievementUnlocked>,
    }


struct AchievementUnlocked has drop, store {
        player: address,
        achievement_id: u64,
        timestamp: u64,
    }

   
    public fun initialize_player(player: &signer) {
        let achievements = PlayerAchievements {
            achievement_ids: vector::empty<u64>(),
            total_score: 0,
            nft_count: 0,
            achievement_events: account::new_event_handle<AchievementUnlocked>(player),
        };
        move_to(player, achievements);
    }

    
    public fun unlock_achievement(
        player: &signer, 
        achievement_id: u64, 
        score_earned: u64
    ) acquires PlayerAchievements {
        let player_addr = signer::address_of(player);
        let achievements = borrow_global_mut<PlayerAchievements>(player_addr);
        
        
        if (!vector::contains(&achievements.achievement_ids, &achievement_id)) {
           
            vector::push_back(&mut achievements.achievement_ids, achievement_id);
            achievements.total_score = achievements.total_score + score_earned;
            achievements.nft_count = achievements.nft_count + 1;
            
           
            event::emit_event(&mut achievements.achievement_events, AchievementUnlocked {
                player: player_addr,
                achievement_id,
                timestamp: timestamp::now_seconds(),
            });
        };
    }
}
