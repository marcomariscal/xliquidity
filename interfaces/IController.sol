pragma solidity >=0.5.17;

interface IController {
  function withdraw(address, uint256) external;

  function balanceOf(address) external view returns (uint256);

  function vaults(address) external view returns (address);

  function strategies(address) external view returns (address);
}
