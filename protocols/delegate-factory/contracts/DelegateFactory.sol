/*
  Copyright 2019 Swap Holdings Ltd.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity 0.5.10;

import "@airswap/delegate/contracts/Delegate.sol";
import "@airswap/indexer/contracts/interfaces/ILocatorWhitelist.sol";
import "@airswap/delegate-factory/contracts/interfaces/IDelegateFactory.sol";

contract DelegateFactory is IDelegateFactory, ILocatorWhitelist {

  mapping(address => bool) internal deployedAddresses;

  /**
    * @notice Create a new Delegate contract
    * @param _swapContract address of the swap contract the peer will deploy with
    * @param _delegateContractOwner address that should be the owner of the peer
    * @param _delegateTradeWallet the wallet the peer will trade from
    * @return delegateContractAddress address address of the peer contract created
    */
  function createDelegate(
    address _swapContract,
    address _delegateContractOwner,
    address _delegateTradeWallet
  ) external returns (address delegateContractAddress) {

    // Ensure an owner for the peer contract is provided.
    require(_delegateContractOwner != address(0),
      'PEER_CONTRACT_OWNER_REQUIRED');

    // Ensure a swap contract is provided.
    require(_swapContract != address(0),
      'SWAP_CONTRACT_REQUIRED');

    delegateContractAddress = address(new Delegate(_swapContract, _delegateContractOwner, _delegateTradeWallet));
    deployedAddresses[delegateContractAddress] = true;

    emit CreateDelegate(delegateContractAddress, _swapContract, _delegateContractOwner, _delegateTradeWallet);

    return delegateContractAddress;
  }

  /**
    * @notice To check whether a locator was deployed
    * @dev Implements ILocatorWhitelist.has
    * @param _locator locator of the peer in question
    * @return bool true if the peer was deployed by this contract
    */
  function has(bytes32 _locator) external view returns (bool) {
    return deployedAddresses[address(bytes20(_locator))];
  }

}
