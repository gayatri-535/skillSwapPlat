package com.skillswap.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.skillswap.model.SwapRequest;
import com.skillswap.service.SwapService;

@RestController
@RequestMapping("/api/swaps")
public class SwapController {

    @Autowired
    private SwapService swapService;

    @PostMapping
    public ResponseEntity<?> createSwap(@RequestBody SwapRequest request) {
        try {
            if (request.requesterId <= 0 || request.receiverId <= 0) {
                return ResponseEntity.badRequest().body("Valid requesterId and receiverId required");
            }
            swapService.createSwap(request);
            return ResponseEntity.ok("Swap request created successfully");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error creating swap: " + e.getMessage());
        }
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<?> accept(@PathVariable int id) {
        try {
            swapService.acceptSwap(id);
            return ResponseEntity.ok("Swap request accepted");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error accepting swap: " + e.getMessage());
        }
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<?> cancel(@PathVariable int id) {
        try {
            swapService.cancelSwap(id);
            return ResponseEntity.ok("Swap request cancelled");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error cancelling swap: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<?> list() {
        try {
            List<SwapRequest> swaps = swapService.listAllSwaps();
            return ResponseEntity.ok(swaps);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error listing swaps: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> listUserSwaps(@PathVariable int userId) {
        try {
            List<SwapRequest> swaps = swapService.listUserSwaps(userId);
            return ResponseEntity.ok(swaps);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error listing user swaps: " + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getSwap(@PathVariable int id) {
        try {
            SwapRequest swap = swapService.getSwapById(id);
            if (swap == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(swap);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error retrieving swap: " + e.getMessage());
        }
    }
}

