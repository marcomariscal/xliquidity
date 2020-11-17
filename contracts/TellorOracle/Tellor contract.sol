pragma solidity ^0.5.0;

import "../contracts/testContracts/TellorMaster.sol";
import "../contracts/libraries/TellorLibrary.sol";//imported for testing ease
import "../contracts/testContracts/Tellor.sol";//imported for testing ease
import "./OracleIDDescriptions.sol";
import "../contracts/interfaces/EIP2362Interface.sol";

/**
* @title UserContract
* This contracts creates for easy integration to the Tellor System
* by allowing smart contracts to read data off Tellor
*/

contract BtcPrice1HourAgoContract is UsingTellor {

  uint256 btcPrice;
  uint256 btcRequetId = 2;

  constructor(address payable _tellorAddress) UsingTellor(_tellorAddress) public {}

  function getBtcPriceBefore1HourAgo() public view returns (uint256) {
    bool _didGet;
    uint _timestamp;
    uint _value;

    // Get the price that is older than an hour (looking back at most 60 values)
    (_didGet, _value, _timestamp) = getDataBefore(btcRequetId, now - 1 hours, 60, 0);

    if(_didGet){
      btcPrice = _value;
    }


  }
}

contract EthPrice1HourAgoContract is UsingTellor {

  uint256 EthPrice;
  uint256 ethRequetId = 2;

  constructor(address payable _tellorAddress) UsingTellor(_tellorAddress) public {}

  function getEthPriceBefore1HourAgo() public view returns (uint256) {
    bool _didGet;
    uint _timestamp;
    uint _value;

    // Get the price that is older than an hour (looking back at most 60 values)
    (_didGet, _value, _timestamp) = getDataBefore(ethRequetId, now - 1 hours, 60, 0);

    if(_didGet){
      ethPrice = _value;
    }
}
}

contract BchPrice1HourAgoContract is UsingTellor {

  uint256 bchPrice;
  uint256 bchRequetId = 2;

  constructor(address payable _tellorAddress) UsingTellor(_tellorAddress) public {}

  function getBchPriceBefore1HourAgo() public view returns (uint256) {
    bool _didGet;
    uint _timestamp;
    uint _value;

    // Get the price that is older than an hour (looking back at most 60 values)
    (_didGet, _value, _timestamp) = getDataBefore(bchRequetId, now - 1 hours, 60, 0);

    if(_didGet){
      bchPrice = _value;
    }

    
  }



    event NewDescriptorSet(address _descriptorSet);

    /*Constructor*/
    /**
    * @dev the constructor sets the storage address and owner
    * @param _storage is the TellorMaster address
    */
    constructor(address payable _storage) public {
        tellorStorageAddress = _storage;
        _tellorm = TellorMaster(tellorStorageAddress);
    }

    /*Functions*/
    /*
    * @dev Allows the owner to set the address for the oracleID descriptors
    * used by the ADO members for price key value pairs standarization
    * _oracleDescriptors is the address for the OracleIDDescriptions contract
    */
    function setOracleIDDescriptors(address _oracleDescriptors) external {
        require(oracleIDDescriptionsAddress == address(0), "Already Set");
        oracleIDDescriptionsAddress = _oracleDescriptors;
        descriptions = OracleIDDescriptions(_oracleDescriptors);
        emit NewDescriptorSet(_oracleDescriptors);
    }

    /**
    * @dev Allows the user to get the latest value for the requestId specified
    * @param _requestId is the requestId to look up the value for
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp
    */
    function getCurrentValue(uint256 _requestId) public view returns (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) {
        return getDataBefore(_requestId,now,1,0);
    }

    /**
    * @dev Allows the user to get the latest value for the requestId specified using the
    * ADO specification for the standard inteface for price oracles
    * @param _bytesId is the ADO standarized bytes32 price/key value pair identifier
    * @return the timestamp, outcome or value/ and the status code (for retreived, null, etc...)
    */
    function valueFor(bytes32 _bytesId) external view returns (int value, uint256 timestamp, uint status) {
        uint _id = descriptions.getTellorIdFromBytes(_bytesId);
        int n = descriptions.getGranularityAdjFactor(_bytesId);
        if (_id > 0){
            bool _didGet;
            uint256 _returnedValue;
            uint256 _timestampRetrieved;
            (_didGet,_returnedValue,_timestampRetrieved) = getDataBefore(_id,now,1,0);
            if(_didGet){
                return (int(_returnedValue)*n,_timestampRetrieved, descriptions.getStatusFromTellorStatus(1));
            }
            else{
                return (0,0,descriptions.getStatusFromTellorStatus(2));
            }
        }
        return (0, 0, descriptions.getStatusFromTellorStatus(0));
    }

    /**
    * @dev Allows the user to get the first value for the requestId before the specified timestamp
    * @param _requestId is the requestId to look up the value for
    * @param _timestamp before which to search for first verified value
    * @param _limit a limit on the number of values to look at
    * @param _offset the number of values to go back before looking for data values
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp
    */
    function getDataBefore(uint256 _requestId, uint256 _timestamp, uint256 _limit, uint256 _offset)
        public
        view
        returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
    {
        uint256 _count = _tellorm.getNewValueCountbyRequestId(_requestId);
        if (_count > 0) {
            for (uint256 i = _count - _offset; i < _count -_offset + _limit; i++) {
                uint256 _time = _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1);
                if(_value > 0 && _time > _timestamp){
                    return(true, _value, _timestampRetrieved);
                }
                else if (_time > 0 && _time <= _timestamp && _tellorm.isInDispute(_requestId,_time) == false) {
                    _value = _tellorm.retrieveData(_requestId, _time);
                    _timestampRetrieved = _time;
                    if(i == _count){
                        return(true, _value, _timestampRetrieved);
                    }
                }
            }
        }
        return (false, 0, 0);
    }
}
}
}
}
