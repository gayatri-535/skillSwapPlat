package com.skillswap.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.skillswap.dao.SwapDao;
import com.skillswap.model.SwapRequest;

@Service
public class SwapService {

    @Autowired
    private SwapDao swapDao;

    public void createSwap(SwapRequest request) {
        try {
            if (request.status == null || request.status.isEmpty()) {
                request.status = "pending";
            }
            swapDao.createSwap(request);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to create swap: " + e.getMessage());
        }
    }

    public SwapRequest getSwapById(int swapId) {
        return swapDao.findById(swapId);
    }

    public List<SwapRequest> listAllSwaps() {
        return swapDao.listSwaps();
    }

    public List<SwapRequest> listUserSwaps(int userId) {
        return swapDao.listSwapsByUser(userId);
    }

    public void acceptSwap(int requestId) {
        try {
            SwapRequest swap = swapDao.findById(requestId);
            if (swap == null) {
                throw new IllegalArgumentException("Swap request not found: " + requestId);
            }
            swapDao.updateStatus(requestId, "accepted");
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to accept swap: " + e.getMessage());
        }
    }

    public void cancelSwap(int requestId) {
        try {
            SwapRequest swap = swapDao.findById(requestId);
            if (swap == null) {
                throw new IllegalArgumentException("Swap request not found: " + requestId);
            }
            swapDao.cancelSwap(requestId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to cancel swap: " + e.getMessage());
        }
    }
}
