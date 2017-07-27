pragma solidity ^0.4.11;

import "./MultiSigWalletWithTimeLock.sol";

contract MultiSigWalletWithTimeLockExceptRemoveAuthorizedAddress is MultiSigWalletWithTimeLock {

    address public PROXY_CONTRACT;

    modifier validRemoveAuthorizedAddressTx(uint transactionId) {
        Transaction storage tx = transactions[transactionId];
        assert(tx.destination == PROXY_CONTRACT);
        assert(bytes4FromBytes(tx.data) == bytes4(sha3("removeAuthorizedAddress(address)")));
        _;
    }

    /// @dev Contract constructor sets initial owners, required number of confirmations, time lock, and proxy address.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    /// @param _secondsTimeLocked Duration needed after a transaction is confirmed and before it becomes executable, in seconds.
    /// @param _proxy Address of Proxy contract.
    function MultiSigWalletWithTimeLockExceptRemoveAuthorizedAddress(
        address[] _owners,
        uint _required,
        uint _secondsTimeLocked,
        address _proxy)
        public
        MultiSigWalletWithTimeLock(_owners, _required, _secondsTimeLocked)
    {
        PROXY_CONTRACT = _proxy;
    }

    /// @dev Allows execution of removeAuthorizedAddress without time lock.
    /// @param transactionId Transaction ID.
    function executeRemoveAuthorizedAddress(uint transactionId)
        public
        notExecuted(transactionId)
        confirmationTimeSet(transactionId)
        validRemoveAuthorizedAddressTx(transactionId)
    {
        Transaction storage tx = transactions[transactionId];
        tx.executed = true;
        if (tx.destination.call.value(tx.value)(tx.data))
            Execution(transactionId);
        else {
            ExecutionFailure(transactionId);
            tx.executed = false;
        }
    }

    /// @dev Takes a tightly packed array's first 4 bytes (given its length is sufficient)
    ///     and pads them to return a proper 'bytes4' type variable
    /// @param data Transaction data array.
    /// @return The first 4 bytes of the input array.
    function bytes4FromBytes(bytes data)
        public
        constant
        returns (bytes4)
    {
        require(data.length >= 4);

        bytes4 first4Bytes;

        assembly {
            first4Bytes := mul(div(mload(add(data, 0x20)), 0x100000000000000000000000000000000000000000000000000000000), 0x100000000000000000000000000000000000000000000000000000000)
        }

        return first4Bytes;
    }
}
