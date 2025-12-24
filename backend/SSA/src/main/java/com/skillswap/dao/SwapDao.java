package com.skillswap.dao;

import com.skillswap.model.SwapRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class SwapDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void createSwap(SwapRequest swap) {
        String sql = "INSERT INTO SwapRequests (requesterId, receiverId, requestedSkill, offeredSkill, status) VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, 
            swap.requesterId, 
            swap.receiverId, 
            swap.requestedSkill, 
            swap.offeredSkill, 
            swap.status != null ? swap.status : "pending"
        );
    }

    public SwapRequest findById(int id) {
        String sql = "SELECT id, requesterId, receiverId, requestedSkill, offeredSkill, status FROM SwapRequests WHERE id = ?";
        List<SwapRequest> swaps = jdbcTemplate.query(sql, (rs, rowNum) -> {
            SwapRequest swap = new SwapRequest();
            swap.id = rs.getInt("id");
            swap.requesterId = rs.getInt("requesterId");
            swap.receiverId = rs.getInt("receiverId");
            swap.requestedSkill = rs.getString("requestedSkill");
            swap.offeredSkill = rs.getString("offeredSkill");
            swap.status = rs.getString("status");
            return swap;
        }, id);
        return swaps.isEmpty() ? null : swaps.get(0);
    }

    public List<SwapRequest> listSwaps() {
        String sql = "SELECT id, requesterId, receiverId, requestedSkill, offeredSkill, status FROM SwapRequests ORDER BY id DESC";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            SwapRequest swap = new SwapRequest();
            swap.id = rs.getInt("id");
            swap.requesterId = rs.getInt("requesterId");
            swap.receiverId = rs.getInt("receiverId");
            swap.requestedSkill = rs.getString("requestedSkill");
            swap.offeredSkill = rs.getString("offeredSkill");
            swap.status = rs.getString("status");
            return swap;
        });
    }

    public List<SwapRequest> listSwapsByUser(int userId) {
        String sql = "SELECT id, requesterId, receiverId, requestedSkill, offeredSkill, status FROM SwapRequests WHERE requesterId = ? OR receiverId = ? ORDER BY id DESC";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            SwapRequest swap = new SwapRequest();
            swap.id = rs.getInt("id");
            swap.requesterId = rs.getInt("requesterId");
            swap.receiverId = rs.getInt("receiverId");
            swap.requestedSkill = rs.getString("requestedSkill");
            swap.offeredSkill = rs.getString("offeredSkill");
            swap.status = rs.getString("status");
            return swap;
        }, userId, userId);
    }

    public void updateStatus(int swapId, String status) {
        String sql = "UPDATE SwapRequests SET status = ? WHERE id = ?";
        jdbcTemplate.update(sql, status, swapId);
    }

    public void cancelSwap(int swapId) {
        String sql = "UPDATE SwapRequests SET status = 'cancelled' WHERE id = ?";
        jdbcTemplate.update(sql, swapId);
    }
}
