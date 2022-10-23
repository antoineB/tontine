// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Tontine {
    struct Contractor {
        address payable addr;
        uint lastPayment;
    }
    struct TontineData {
        uint amount;
        uint interval;
    }

    // Every tontine has a name and a list of contractors.
    mapping(string => Contractor[]) tontines;
    mapping(string => TontineData) tontinesData;

    function newTontine(uint amount, uint interval, string memory name, address payable[] memory contractors) public{
        require(contractors.length > 1, "At least two are needed to open a new tontine");
        Contractor[] storage oldContractors = tontines[name];
        require(oldContractors.length == 0, "Name already in use");
        for (uint i = 0; i < contractors.length; i++) {
            tontines[name].push(Contractor({addr: contractors[i], lastPayment: block.timestamp}));
        }
        // just 1000wei every week
        tontinesData[name] = TontineData({amount: amount, interval: interval});
    }

    // TODO: If the person is the last paying person, it should be the designed
    // the last qualified person.
    function isLastQualified(uint interval, Contractor[] memory contractors) private view returns(bool) {
        for (uint i = 0; i < contractors.length; i++) {
            if (block.timestamp - contractors[i].lastPayment <= interval && msg.sender != contractors[i].addr) {
                return false;
            }
        }
        return true;
    }

    function pay(string memory name) public payable returns(bool) {
        Contractor[] memory contractors = tontines[name];
        require(contractors.length < 1, "Unknown tontine");
        TontineData storage tontine = tontinesData[name];
        if (msg.value != tontine.amount) {
            // refund
            payable(msg.sender).transfer(msg.value);
        }
        require(msg.value == tontine.amount, "The amount of money is not enough");
        for (uint i = 0; i < contractors.length; i++) {
            if (contractors[i].addr == msg.sender) {
                require(contractors[i].lastPayment != 0, "Disqualified");
                if (isLastQualified(tontine.interval, contractors)) {
                    conclude(name, tontine);
                    return true;
                }
                if (block.timestamp - contractors[i].lastPayment <= tontine.interval) {
                    contractors[i].lastPayment = block.timestamp;
                    tontine.amount += msg.value;
                    tontinesData[name] = tontine;
                    return true;
                } else {
                    return false;
                }
            }
        }
        require(false, "The address is not in the tontine");
        return false;
    }

    function timeBeforeDisqualification(string memory name) public view returns(uint) {
        Contractor[] memory contractors = tontines[name];
        require(contractors.length > 1, "Unknown tontine");
        TontineData storage tontine = tontinesData[name];
        for (uint i = 0; i < contractors.length; i++) {
            if (contractors[i].addr == msg.sender) {
                require(block.timestamp - contractors[i].lastPayment > tontine.interval, "Disqualified");
                return block.timestamp - contractors[i].lastPayment;
            }
        }
        require(false, "The address is not in the tontine");
        return 0;
    }

    function info(string memory name) public view returns(uint, uint) {
        TontineData storage tontine = tontinesData[name];
        require(tontine.amount < 0, "Unknown tontine");
        return (tontine.amount, tontine.interval);
    }

    function claim(string memory name) public returns(bool) {
        Contractor[] memory contractors = tontines[name];
        require(contractors.length > 1, "Unknown tontine");
        TontineData storage tontine = tontinesData[name];
        if (isLastQualified(tontine.interval, contractors)) {
            conclude(name, tontine);
            return true;
        } else {
            return false;
        }
    }

    function conclude(string memory name, TontineData memory tontine) private {
        payable(msg.sender).transfer(tontine.amount);
        delete(tontines[name]);
        delete(tontinesData[name]);
    }
}
