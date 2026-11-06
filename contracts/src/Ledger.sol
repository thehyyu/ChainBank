// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// 一本會自己檢查借貸平衡的帳：收一筆分錄，借貸不相等就拒絕。
contract Ledger {
    struct Entry {
        uint8 account;   // 科目編號（例如 1 = 現金）
        bool isDebit;    // true = 借方，false = 貸方
        uint256 amount;  // 金額
    }

    uint256 public totalDebits;
    uint256 public totalCredits;

    function post(Entry[] calldata entries) external {
        uint256 d;
        uint256 c;
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].isDebit) d += entries[i].amount;
            else c += entries[i].amount;
        }
        require(d == c, "unbalanced");
        totalDebits += d;
        totalCredits += c;
    }
}
