// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ledger} from "../src/Ledger.sol";

contract LedgerTest is Test {
    Ledger ledger;

    function setUp() public {
        ledger = new Ledger();
    }

    // 測試 1：平衡的分錄能記進去（借現金 100、貸股本 100）
    function test_BalancedEntryIsPosted() public {
        Ledger.Entry[] memory e = new Ledger.Entry[](2);
        e[0] = Ledger.Entry(1, true, 100);
        e[1] = Ledger.Entry(2, false, 100);
        ledger.post(e);
        assertEq(ledger.totalDebits(), 100);
        assertEq(ledger.totalCredits(), 100);
    }

    // 測試 2：不平衡的分錄被拒絕（借 100、貸 90）
    function test_UnbalancedEntryReverts() public {
        Ledger.Entry[] memory e = new Ledger.Entry[](2);
        e[0] = Ledger.Entry(1, true, 100);
        e[1] = Ledger.Entry(2, false, 90);
        vm.expectRevert("unbalanced");
        ledger.post(e);
    }

    // 測試 3（fuzz）：不管餵進什麼隨機分錄，借貸總額永遠相等
    function testFuzz_TotalsAlwaysEqual(uint96[] memory amounts, bool[] memory sides) public {
        uint256 n = amounts.length < sides.length ? amounts.length : sides.length;
        Ledger.Entry[] memory e = new Ledger.Entry[](n);
        for (uint256 i = 0; i < n; i++) {
            e[i] = Ledger.Entry(1, sides[i], amounts[i]);
        }
        try ledger.post(e) {} catch {}
        assertEq(ledger.totalDebits(), ledger.totalCredits());
    }
}
