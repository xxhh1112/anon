pragma solidity 0.7.3;

import "./Anchor.sol";

contract NativeAnchor is Anchor {
  constructor(
    IVerifier _verifier,
    uint256 _denomination,
    uint32 _merkleTreeHeight,
    address _operator,
  ) Anchor(_verifier, _denomination, _merkleTreeHeight, _operator) public {
  }

  function _processDeposit() override internal {
    require(msg.value == denomination, "Please send `mixDenomination` ETH along with transaction");
  }

  function _processWithdraw(address payable _recipient, address payable _relayer, uint256 _fee, uint256 _refund) override internal {
    // sanity checks
    require(msg.value == 0, "Message value is supposed to be zero for ETH instance");
    require(_refund == 0, "Refund value is supposed to be zero for ETH instance");

    (bool success, ) = _recipient.call{value:  denomination - _fee}("");
    require(success, "payment to _recipient did not go thru");
    if (_fee > 0) {
      (success, ) = _relayer.call{value: _fee}("");
      require(success, "payment to _relayer did not go thru");
    }
  }
}
