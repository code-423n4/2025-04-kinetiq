# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 26 |
| [GAS-2](#GAS-2) | Use assembly to check for `address(0)` | 44 |
| [GAS-3](#GAS-3) | Using bools for storage incurs overhead | 5 |
| [GAS-4](#GAS-4) | Cache array length outside of loop | 8 |
| [GAS-5](#GAS-5) | State variables should be cached in stack variables rather than re-reading them from storage | 4 |
| [GAS-6](#GAS-6) | Use calldata instead of memory for function arguments that do not get mutated | 1 |
| [GAS-7](#GAS-7) | For Operations that will not overflow, you could use unchecked | 174 |
| [GAS-8](#GAS-8) | Use Custom Errors instead of Revert Strings to save Gas | 150 |
| [GAS-9](#GAS-9) | Avoid contract existence checks by using low level calls | 3 |
| [GAS-10](#GAS-10) | Stack variable used as a cheaper cache for a state variable is only used once | 1 |
| [GAS-11](#GAS-11) | State variables only set in the constructor should be declared `immutable` | 1 |
| [GAS-12](#GAS-12) | Functions guaranteed to revert when called by normal users can be marked `payable` | 43 |
| [GAS-13](#GAS-13) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 13 |
| [GAS-14](#GAS-14) | Using `private` rather than `public` for constants, saves gas | 21 |
| [GAS-15](#GAS-15) | Splitting require() statements that use && saves gas | 2 |
| [GAS-16](#GAS-16) | Increments/decrements can be unchecked in for-loops | 9 |
| [GAS-17](#GAS-17) | Use != 0 instead of > 0 for unsigned integer comparison | 41 |
### <a name="GAS-1"></a>[GAS-1] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (26)*:
```solidity
File: ./src/OracleManager.sol

204:                     totalBalance += balance;

205:                     totalUptimeScore += uptimeScore;

206:                     totalSpeedScore += speedScore;

207:                     totalIntegrityScore += integrityScore;

208:                     totalSelfStakeScore += selfStakeScore;

209:                     totalRewardAmount += accRewardAmount;

210:                     totalSlashAmount += accSlashAmount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingAccountant.sol

129:         totalStaked += amount;

134:         totalClaimed += amount;

205:             totalKHYPESupply += IERC20(tokenAddress).totalSupply();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

239:         totalStaked += msg.value;

288:         totalQueuedWithdrawals += hypeAmount;

318:             totalAmount += _processConfirmation(msg.sender, withdrawalIds[i]);

395:         totalClaimed += hypeAmount;

420:             truncatedAmount += 1;

464:                 hypeBuffer += remainder;

643:             processedCount += withdrawalsProcessed;

647:             processedCount += depositsProcessed;

651:             processedCount += withdrawalsProcessed;

657:                 processedCount += depositsProcessed;

938:         _cancelledWithdrawalAmount += hypeAmount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

267:             totalAmount += request.amount;

416:         totalRewards += amount;

417:         validatorRewards[validator] += amount;

434:         totalSlashing += amount;

435:         validatorSlashing[validator] += amount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="GAS-2"></a>[GAS-2] Use assembly to check for `address(0)`
*Saves 6 gas per instance*

*Instances (44)*:
```solidity
File: ./src/KHYPE.sol

57:         require(admin != address(0), "Invalid admin address");

58:         require(_pauserRegistry != address(0), "Invalid pauser registry address");

59:         require(minter != address(0), "Invalid minter address");

60:         require(burner != address(0), "Invalid burner address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

77:         require(_pauserRegistry != address(0), "Invalid pauser registry");

78:         require(_validatorManager != address(0), "Invalid validator manager");

99:         require(adapter != address(0), "Invalid oracle address");

148:         require(validator != address(0), "Invalid validator address");

242:         if (address(sanityChecker) != address(0)) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

57:         require(admin != address(0), "Invalid admin address");

58:         require(pauser != address(0), "Invalid pauser address");

59:         require(unpauser != address(0), "Invalid unpauser address");

60:         require(pauseAll != address(0), "Invalid pauseAll address");

130:         require(contractAddress != address(0), "Invalid contract address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

63:         require(admin != address(0), "Invalid admin address");

64:         require(manager != address(0), "Invalid manager address");

65:         require(_validatorManager != address(0), "Invalid validator manager");

83:         require(manager != address(0), "Invalid manager address");

84:         require(kHYPEToken != address(0), "Invalid kHYPE token address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

154:         require(_pauserRegistry != address(0), "Invalid pauser registry");

155:         require(_kHYPE != address(0), "Invalid kHYPE token");

156:         require(_validatorManager != address(0), "Invalid validator manager");

157:         require(_stakingAccountant != address(0), "Invalid staking accountant");

158:         require(admin != address(0), "Invalid admin address");

159:         require(operator != address(0), "Invalid operator address");

160:         require(manager != address(0), "Invalid manager address");

161:         require(_treasury != address(0), "Invalid treasury address");

292:         require(currentDelegation != address(0), "No delegation set");

515:         require(validator != address(0), "Invalid validator address");

841:             require(accounts[i] != address(0), "Invalid address");

987:         require(newTreasury != address(0), "Invalid treasury address");

1050:         require(validator != address(0), "Invalid validator address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

110:         require(admin != address(0), "Invalid admin address");

111:         require(manager != address(0), "Invalid manager address");

112:         require(_oracle != address(0), "Invalid oracle address");

113:         require(_pauserRegistry != address(0), "Invalid pauser registry");

132:         require(validator != address(0), "Invalid validator address");

208:             require(validators[i] != address(0), "Invalid validator address");

451:         require(stakingManager != address(0), "Invalid staking manager");

465:         require(validator != address(0), "No delegation set");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultAdapter.sol

18:         require(_defaultOracle != address(0), "Invalid oracle address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

61:         require(admin != address(0), "Invalid admin");

62:         require(operator != address(0), "Invalid operator");

91:         require(validator != address(0), "Invalid validator");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="GAS-3"></a>[GAS-3] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (5)*:
```solidity
File: ./src/OracleManager.sol

56:     mapping(address => bool) private activeOracles;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

34:     mapping(address => bool) public isPaused;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingManager.sol

85:     bool public stakingPaused;

86:     bool public withdrawalPaused;

87:     bool public whitelistEnabled;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="GAS-4"></a>[GAS-4] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (8)*:
```solidity
File: ./src/PauserRegistry.sol

77:         for (uint256 i = 0; i < contracts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingManager.sol

317:         for (uint256 i = 0; i < withdrawalIds.length; i++) {

346:         for (uint256 i = 0; i < validators.length; ) {

567:         for (uint256 i = 0; i < validators.length; ) {

840:         for (uint256 i = 0; i < accounts.length; i++) {

853:         for (uint256 i = 0; i < accounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

207:         for (uint256 i = 0; i < validators.length; ) {

259:         for (uint256 i = 0; i < validators.length; ) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="GAS-5"></a>[GAS-5] State variables should be cached in stack variables rather than re-reading them from storage
The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (100 gas) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*Saves 100 gas per instance*

*Instances (4)*:
```solidity
File: ./src/StakingManager.sol

452:                 emit BufferIncreased(amountToBuffer, hypeBuffer);

527:                 emit BufferDecreased(amountFromBuffer, hypeBuffer);

1018:         emit TokenWithdrawnFromSpot(tokenId, amount, treasury);

1037:         emit TokenRescued(token, amount, treasury);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="GAS-6"></a>[GAS-6] Use calldata instead of memory for function arguments that do not get mutated
When a function with a `memory` array is called externally, the `abi.decode()` step has to use a for-loop to copy each index of the `calldata` to the `memory` index. Each iteration of this for-loop costs at least 60 gas (i.e. `60 * <mem_array>.length`). Using `calldata` directly bypasses this loop. 

If the array is passed to an `internal` function which passes the array to another internal function where the array is modified and therefore `memory` is used in the `external` call, it's still more gas-efficient to use `calldata` when the `external` function uses modifiers, since the modifiers may prevent the internal functions from being called. Structs have the same overhead as an array of length one. 

 *Saves 60 gas per instance*

*Instances (1)*:
```solidity
File: ./src/PauserRegistry.sol

54:         address[] memory contracts

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

### <a name="GAS-7"></a>[GAS-7] For Operations that will not overflow, you could use unchecked

*Instances (174)*:
```solidity
File: ./src/KHYPE.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

8: import {IPauserRegistry} from "../src/interfaces/IPauserRegistry.sol";

23:     IPauserRegistry public pauserRegistry; // Add this state variable

27:     bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // Role allowed to mint new tokens

28:     bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); // Role allowed to burn tokens

64:         __ERC20Permit_init(name); // Initialize permit functionality for gasless transactions

88:         _mint(to, amount); // TODO update the logic with mirror token

97:         _burn(from, amount); // TODO update the logic with mirror token

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

7: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

8: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

9: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

10: import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

11: import {IValidatorManager} from "./interfaces/IValidatorManager.sol";

12: import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";

13: import {IOracleManager} from "./interfaces/IOracleManager.sol";

14: import {IOracleAdapter} from "./oracles/IOracleAdapter.sol";

15: import {IValidatorSanityChecker} from "./validators/IValidatorSanityChecker.sol";

93:         MIN_VALID_ORACLES = 1; // Default to 1, can be changed by admin

145:             block.timestamp >= lastValidatorUpdate[validator] + MIN_UPDATE_INTERVAL,

171:                     ++i;

172:                 } // Increment before continue

173:                 continue; // Skip inactive oracles

187:                 if (block.timestamp > timestamp + MAX_ORACLE_STALENESS) {

191:                         ++i;

204:                     totalBalance += balance;

205:                     totalUptimeScore += uptimeScore;

206:                     totalSpeedScore += speedScore;

207:                     totalIntegrityScore += integrityScore;

208:                     totalSelfStakeScore += selfStakeScore;

209:                     totalRewardAmount += accRewardAmount;

210:                     totalSlashAmount += accSlashAmount;

211:                     validOracleCount++;

218:                 ++i;

219:             } // Single increment point at the end of the loop

226:         uint256 avgBalance = totalBalance / validOracleCount;

227:         uint256 avgUptimeScore = totalUptimeScore / validOracleCount;

228:         uint256 avgSpeedScore = totalSpeedScore / validOracleCount;

229:         uint256 avgIntegrityScore = totalIntegrityScore / validOracleCount;

230:         uint256 avgSelfStakeScore = totalSelfStakeScore / validOracleCount;

231:         uint256 avgRewardAmount = totalRewardAmount / validOracleCount;

232:         uint256 avgSlashAmount = totalSlashAmount / validOracleCount;

273:             uint256 newRewardAmount = avgRewardAmount - previousRewards;

277:             uint256 newSlashAmount = avgSlashAmount - previousSlashing;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

8: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

9: import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";

77:         for (uint256 i = 0; i < contracts.length; i++) {

114:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

8: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

9: import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

10: import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

11: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

12: import {IValidatorManager} from "./interfaces/IValidatorManager.sol";

13: import {IStakingAccountant} from "./interfaces/IStakingAccountant.sol";

110:         for (uint256 i = 0; i < length; i++) {

129:         totalStaked += amount;

134:         totalClaimed += amount;

203:         for (uint256 i = 0; i < uniqueTokenCount; i++) {

205:             totalKHYPESupply += IERC20(tokenAddress).totalSupply();

210:             return 1e18; // 1:1 ratio with 18 decimals precision

216:         uint256 totalHYPE = totalStaked + rewardsAmount - totalClaimed - slashingAmount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

8: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

9: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

10: import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

11: import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

12: import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

14: import {IValidatorManager} from "./interfaces/IValidatorManager.sol";

15: import {IStakingManager} from "./interfaces/IStakingManager.sol";

16: import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";

17: import {IStakingAccountant} from "./interfaces/IStakingAccountant.sol";

18: import {L1Write} from "./lib/L1Write.sol";

19: import {KHYPE} from "./KHYPE.sol";

50:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

69:     uint256 public totalStaked; // Total HYPE staked

70:     uint256 public totalClaimed; // Total HYPE claimed/withdrawn

71:     uint256 public totalQueuedWithdrawals; // Total amount of all pending withdrawal requests

74:     uint256 public hypeBuffer; // Current buffer amount

75:     uint256 public targetBuffer; // Target buffer size

78:     uint256 public stakingLimit; // Maximum total stake (0 = unlimited)

79:     uint256 public minStakeAmount; // Minimum stake per call

80:     uint256 public maxStakeAmount; // Maximum stake per call (0 = unlimited)

81:     uint256 public withdrawalDelay; // Delay period for withdrawals

82:     uint256 public unstakeFeeRate; // Fee rate in basis points (10 = 0.1%)

98:     L1Operation[] private _pendingWithdrawals; // UserWithdrawal and RebalanceWithdrawal

99:     L1Operation[] private _pendingDeposits; // UserDeposit and RebalanceDeposit

235:             uint256 netStaked = totalStaked + rewardsAmount - totalClaimed;

236:             require(netStaked + msg.value <= stakingLimit, "Staking limit reached");

239:         totalStaked += msg.value;

270:         uint256 postFeeKHYPE = kHYPEAmount - kHYPEFee;

287:         nextWithdrawalId[msg.sender]++;

288:         totalQueuedWithdrawals += hypeAmount;

317:         for (uint256 i = 0; i < withdrawalIds.length; i++) {

318:             totalAmount += _processConfirmation(msg.sender, withdrawalIds[i]);

353:                 ++i;

382:         if (request.hypeAmount == 0 || block.timestamp < request.timestamp + withdrawalDelay) {

391:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

394:         totalQueuedWithdrawals -= hypeAmount;

395:         totalClaimed += hypeAmount;

416:         truncatedAmount = amount / 1e10;

420:             truncatedAmount += 1;

447:                 uint256 bufferSpace = target - currentBuffer;

449:                 hypeBuffer = currentBuffer + amountToBuffer;

450:                 amount -= amountToBuffer;

464:                 hypeBuffer += remainder;

465:                 amount -= remainder;

525:                 hypeBuffer = currentBuffer - amountFromBuffer;

526:                 amount -= amountFromBuffer;

588:                 ++i;

643:             processedCount += withdrawalsProcessed;

647:             processedCount += depositsProcessed;

651:             processedCount += withdrawalsProcessed;

655:                 uint256 depositBatchSize = batchSize - withdrawalsProcessed;

657:                 processedCount += depositsProcessed;

663:             (_pendingWithdrawals.length - _withdrawalProcessingIndex) +

664:                 (_pendingDeposits.length - _depositProcessingIndex)

680:         uint256 endIndex = _withdrawalProcessingIndex + batchSize;

688:         for (uint256 i = _withdrawalProcessingIndex; i < endIndex; i++) {

701:             processedCount++;

728:         uint256 endIndex = _depositProcessingIndex + batchSize;

736:         for (uint256 i = _depositProcessingIndex; i < endIndex; i++) {

744:             processedCount++;

761:         processL1Operations(0); // Process all operations

840:         for (uint256 i = 0; i < accounts.length; i++) {

853:         for (uint256 i = 0; i < accounts.length; i++) {

928:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

932:         totalQueuedWithdrawals -= hypeAmount;

935:         kHYPE.transfer(user, kHYPEAmount + kHYPEFee);

938:         _cancelledWithdrawalAmount += hypeAmount;

972:         emit L1OperationsQueueReset(withdrawalsLength + depositsLength);

980:         require(newRate <= 1000, "Fee rate too high"); // Max 10%

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

4: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

5: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

6: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

7: import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

8: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

9: import {IValidatorManager} from "./interfaces/IValidatorManager.sol";

10: import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";

11: import {IStakingManager} from "./interfaces/IStakingManager.sol";

54:     uint256 public totalSlashing; // In 8 decimals

57:     uint256 public totalRewards; // In 8 decimals

146:         _validatorIndexes.set(validator, _validators.length - 1);

214:                 ++i;

231:         (bool exists /* uint256 index */, ) = _validatorIndexes.tryGet(validator);

267:             totalAmount += request.amount;

276:                 ++i;

331:             active: _validators[index].active // Preserve active state

378:                 count++;

381:                 ++i;

416:         totalRewards += amount;

417:         validatorRewards[validator] += amount;

434:         totalSlashing += amount;

435:         validatorSlashing[validator] += amount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultAdapter.sol

4: import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

5: import {IOracleAdapter} from "./IOracleAdapter.sol";

13:     address public immutable defaultOracle; // External oracle contract

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

4: import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

5: import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

18:         uint256 uptime; // 0-10000 basis points

19:         uint256 speed; // 0-10000 basis points

20:         uint256 integrity; // 0-10000 basis points

21:         uint256 stake; // 0-10000 basis points

29:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

84:         uint256 uptime, // 0-10000 basis points

85:         uint256 speed, // 0-10000 basis points

86:         uint256 integrity, // 0-10000 basis points

87:         uint256 stake, // 0-10000 basis points

98:         require(block.timestamp >= metrics.lastUpdateTime + MIN_UPDATE_INTERVAL, "Update too frequent");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

```solidity
File: ./src/oracles/IOracleAdapter.sol

4: import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/IOracleAdapter.sol)

### <a name="GAS-8"></a>[GAS-8] Use Custom Errors instead of Revert Strings to save Gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (150)*:
```solidity
File: ./src/KHYPE.sol

33:         require(!pauserRegistry.isPaused(address(this)), "Contract is paused");

57:         require(admin != address(0), "Invalid admin address");

58:         require(_pauserRegistry != address(0), "Invalid pauser registry address");

59:         require(minter != address(0), "Invalid minter address");

60:         require(burner != address(0), "Invalid burner address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

61:         require(!pauserRegistry.isPaused(address(this)), "Contract is paused");

77:         require(_pauserRegistry != address(0), "Invalid pauser registry");

78:         require(_validatorManager != address(0), "Invalid validator manager");

79:         require(_maxPerformanceBound > 0, "Invalid max performance bound");

99:         require(adapter != address(0), "Invalid oracle address");

100:         require(IOracleAdapter(adapter).supportsInterface(type(IOracleAdapter).interfaceId), "Invalid adapter");

115:         require(authorizedOracles.contains(adapter), "Oracle not authorized");

148:         require(validator != address(0), "Invalid validator address");

151:         require(!validatorManager.hasPendingRebalance(validator), "Validator has pending rebalance");

154:         require(oracleCount > 0, "No oracles authorized");

223:         require(validOracleCount >= MIN_VALID_ORACLES, "Insufficient valid oracles");

291:         require(newBound > 0, "Invalid bound");

297:         require(newInterval > 0, "Invalid interval");

303:         require(newStaleness > 0, "Invalid staleness period");

315:         require(newMinimum > 0, "Minimum must be greater than zero");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

57:         require(admin != address(0), "Invalid admin address");

58:         require(pauser != address(0), "Invalid pauser address");

59:         require(unpauser != address(0), "Invalid unpauser address");

60:         require(pauseAll != address(0), "Invalid pauseAll address");

89:         require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

90:         require(!isPaused[contractAddress], "Contract already paused");

101:         require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

102:         require(isPaused[contractAddress], "Contract not paused");

130:         require(contractAddress != address(0), "Invalid contract address");

131:         require(!_authorizedContracts.contains(contractAddress), "Contract already authorized");

142:         require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

50:         require(_authorizedManagers.contains(msg.sender), "Not authorized");

63:         require(admin != address(0), "Invalid admin address");

64:         require(manager != address(0), "Invalid manager address");

65:         require(_validatorManager != address(0), "Invalid validator manager");

83:         require(manager != address(0), "Invalid manager address");

84:         require(kHYPEToken != address(0), "Invalid kHYPE token address");

85:         require(!_authorizedManagers.contains(manager), "Already authorized");

102:         require(exists, "Manager not found");

146:         require(exists, "Manager not authorized");

155:         require(index < _authorizedManagers.length(), "Index out of bounds");

164:         require(index < _uniqueTokens.length(), "Index out of bounds");

187:         require(exchangeRatio > 0, "Invalid exchange ratio");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

108:         require(!pauserRegistry.isPaused(address(this)), "Contract is paused");

113:         require(!stakingPaused, "Staking is paused");

118:         require(!withdrawalPaused, "Withdrawals are paused");

154:         require(_pauserRegistry != address(0), "Invalid pauser registry");

155:         require(_kHYPE != address(0), "Invalid kHYPE token");

156:         require(_validatorManager != address(0), "Invalid validator manager");

157:         require(_stakingAccountant != address(0), "Invalid staking accountant");

158:         require(admin != address(0), "Invalid admin address");

159:         require(operator != address(0), "Invalid operator address");

160:         require(manager != address(0), "Invalid manager address");

161:         require(_treasury != address(0), "Invalid treasury address");

164:         require(_minStakeAmount > 0, "Invalid min stake amount");

166:             require(_maxStakeAmount > _minStakeAmount, "Invalid max stake amount");

169:             require(_stakingLimit > _maxStakeAmount && _stakingLimit > _minStakeAmount, "Invalid staking limit");

222:             require(isWhitelisted(msg.sender), "Address not whitelisted");

226:         require(msg.value >= minStakeAmount, "Stake amount below minimum");

228:             require(msg.value <= maxStakeAmount, "Stake amount above maximum");

236:             require(netStaked + msg.value <= stakingLimit, "Staking limit reached");

259:             require(isWhitelisted(msg.sender), "Address not whitelisted");

262:         require(kHYPEAmount > 0, "Invalid amount");

263:         require(kHYPE.balanceOf(msg.sender) >= kHYPEAmount, "Insufficient kHYPE balance");

292:         require(currentDelegation != address(0), "No delegation set");

304:         require(amount > 0, "No valid withdrawal request");

305:         require(address(this).balance >= amount, "Insufficient contract balance");

311:         require(success, "Transfer failed");

323:             require(address(this).balance >= totalAmount, "Insufficient contract balance");

329:             require(success, "Transfer failed");

342:         require(msg.sender == address(validatorManager), "Only ValidatorManager");

343:         require(validators.length == amounts.length, "Length mismatch");

344:         require(validators.length > 0, "Empty arrays");

347:             require(amounts[i] > 0, "Invalid amount");

363:         require(msg.sender == address(validatorManager), "Only ValidatorManager");

364:         require(amount > 0, "Invalid amount");

365:         require(address(this).balance >= amount, "Insufficient balance");

391:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

424:         require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");

441:             require(amount % 1e10 == 0, "Amount must be divisible by 1e10");

477:             require(success, "Failed to send HYPE to L1");

488:             require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");

503:             revert("unrecognized operation type");

515:         require(validator != address(0), "Invalid validator address");

516:         require(amount > 0, "Invalid withdrawal amount");

538:             revert("unrecognized operation type");

562:         require(validators.length == amounts.length, "Length mismatch");

563:         require(validators.length == operationTypes.length, "Length mismatch");

564:         require(validators.length > 0, "Empty arrays");

574:                 require(validatorManager.validatorActiveState(validators[i]), "Validator not active");

690:             require(op.amount <= type(uint64).max, "Amount exceeds uint64 max");

738:             require(op.amount <= type(uint64).max, "Amount exceeds uint64 max");

780:             require(newStakingLimit > maxStakeAmount && newStakingLimit > minStakeAmount, "Invalid staking limit");

792:         require(newMinStakeAmount > 0, "Invalid min stake amount");

793:         require(newMinStakeAmount % 1e10 == 0, "Amount must be divisible by 1e10");

801:             require(newMaxStakeAmount > minStakeAmount, "Max stake must be greater than min");

804:             require(newMaxStakeAmount <= stakingLimit, "Max stake must be less than limit");

841:             require(accounts[i] != address(0), "Invalid address");

921:         require(request.hypeAmount > 0, "No such withdrawal request");

928:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

947:         require(_cancelledWithdrawalAmount > 0, "No cancelled withdrawals");

948:         require(address(this).balance >= _cancelledWithdrawalAmount, "Insufficient HYPE balance");

980:         require(newRate <= 1000, "Fee rate too high"); // Max 10%

987:         require(newTreasury != address(0), "Invalid treasury address");

1008:         require(amount > 0, "Invalid amount");

1029:         require(amount > 0, "Invalid amount");

1032:         require(token != address(kHYPE), "Cannot withdraw kHYPE or HYPE");

1050:         require(validator != address(0), "Invalid validator address");

1051:         require(amount > 0, "Invalid withdrawal amount");

1055:         require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

86:         require(!pauserRegistry.isPaused(address(this)), "Contract is paused");

91:         require(_validatorIndexes.contains(validator), "Validator does not exist");

96:         require(validatorActiveState(validator), "Validator not active");

110:         require(admin != address(0), "Invalid admin address");

111:         require(manager != address(0), "Invalid manager address");

112:         require(_oracle != address(0), "Invalid oracle address");

113:         require(_pauserRegistry != address(0), "Invalid pauser registry");

132:         require(validator != address(0), "Invalid validator address");

133:         require(!_validatorIndexes.contains(validator), "Validator already exists");

157:         require(hasRole(MANAGER_ROLE, msg.sender), "Not authorized");

160:         require(exists, "Validator does not exist");

163:         require(validatorData.active, "Validator already inactive");

179:         require(exists, "Validator does not exist");

182:         require(!validatorData.active, "Validator already active");

183:         require(!_validatorsWithPendingRebalance.contains(validator), "Validator has pending rebalance");

204:         require(validators.length == withdrawalAmounts.length, "Length mismatch");

205:         require(validators.length > 0, "Empty arrays");

208:             require(validators[i] != address(0), "Invalid validator address");

228:         require(!_validatorsWithPendingRebalance.contains(validator), "Validator has pending rebalance");

229:         require(withdrawalAmount > 0, "Invalid withdrawal amount");

232:         require(exists, "Validator does not exist");

254:         require(_validatorsWithPendingRebalance.length() > 0, "No pending requests");

255:         require(validators.length > 0, "Empty array");

261:             require(_validatorsWithPendingRebalance.contains(validator), "No pending request");

265:             require(request.staking == stakingManager, "Invalid staking manager for rebalance");

393:         require(index < length, "Index out of bounds");

413:         require(amount > 0, "Invalid reward amount");

431:         require(amount > 0, "Invalid slash amount");

451:         require(stakingManager != address(0), "Invalid staking manager");

465:         require(validator != address(0), "No delegation set");

466:         require(validatorActiveState(validator), "Delegated validator not active");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultAdapter.sol

18:         require(_defaultOracle != address(0), "Invalid oracle address");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

61:         require(admin != address(0), "Invalid admin");

62:         require(operator != address(0), "Invalid operator");

91:         require(validator != address(0), "Invalid validator");

92:         require(uptime <= BASIS_POINTS, "Uptime score exceeds BASIS_POINTS");

93:         require(speed <= BASIS_POINTS, "Speed score exceeds BASIS_POINTS");

94:         require(integrity <= BASIS_POINTS, "Integrity score exceeds BASIS_POINTS");

95:         require(stake <= BASIS_POINTS, "Stake score exceeds BASIS_POINTS");

98:         require(block.timestamp >= metrics.lastUpdateTime + MIN_UPDATE_INTERVAL, "Update too frequent");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="GAS-9"></a>[GAS-9] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (3)*:
```solidity
File: ./src/StakingManager.sol

263:         require(kHYPE.balanceOf(msg.sender) >= kHYPEAmount, "Insufficient kHYPE balance");

391:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

928:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="GAS-10"></a>[GAS-10] Stack variable used as a cheaper cache for a state variable is only used once
If the variable is only accessed once, it's cheaper to use the state variable directly that one time, and save the **3 gas** the extra stack assignment would spend

*Instances (1)*:
```solidity
File: ./src/StakingManager.sol

988:         address oldTreasury = treasury;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="GAS-11"></a>[GAS-11] State variables only set in the constructor should be declared `immutable`
Variables only set in the constructor and never edited afterwards should be marked as immutable, as it would avoid the expensive storage-writing operation in the constructor (around **20 000 gas** per variable) and replace the expensive storage-reading operations (around **2100 gas** per reading) to a less expensive value reading (**3 gas**)

*Instances (1)*:
```solidity
File: ./src/oracles/DefaultAdapter.sol

19:         defaultOracle = _defaultOracle;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

### <a name="GAS-12"></a>[GAS-12] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (43)*:
```solidity
File: ./src/KHYPE.sol

87:     function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {

96:     function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

98:     function authorizeOracleAdapter(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

108:     function deauthorizeOracle(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

114:     function setOracleActive(address adapter, bool active) external whenNotPaused onlyRole(MANAGER_ROLE) {

142:     function generatePerformance(address validator) external whenNotPaused onlyRole(OPERATOR_ROLE) returns (bool) {

290:     function setMaxPerformanceBound(uint256 newBound) external onlyRole(OPERATOR_ROLE) {

296:     function setMinUpdateInterval(uint256 newInterval) external onlyRole(MANAGER_ROLE) {

302:     function setMaxOracleStaleness(uint256 newStaleness) external onlyRole(MANAGER_ROLE) {

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {

314:     function setMinValidOracles(uint256 newMinimum) external onlyRole(MANAGER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

88:     function pauseContract(address contractAddress) external onlyRole(PAUSER_ROLE) {

100:     function unpauseContract(address contractAddress) external onlyRole(UNPAUSER_ROLE) {

111:     function emergencyPauseAll() external onlyRole(PAUSE_ALL_ROLE) {

129:     function authorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

141:     function deauthorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

82:     function authorizeStakingManager(address manager, address kHYPEToken) external onlyRole(MANAGER_ROLE) {

99:     function deauthorizeStakingManager(address manager) external override onlyRole(DEFAULT_ADMIN_ROLE) {

128:     function recordStake(uint256 amount) external override onlyAuthorizedManager {

133:     function recordClaim(uint256 amount) external override onlyAuthorizedManager {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

627:     function processL1Operations(uint256 batchSize) public onlyRole(OPERATOR_ROLE) whenNotPaused {

773:     function setTargetBuffer(uint256 newTargetBuffer) external onlyRole(MANAGER_ROLE) {

778:     function setStakingLimit(uint256 newStakingLimit) external onlyRole(MANAGER_ROLE) {

791:     function setMinStakeAmount(uint256 newMinStakeAmount) external onlyRole(MANAGER_ROLE) {

799:     function setMaxStakeAmount(uint256 newMaxStakeAmount) external onlyRole(MANAGER_ROLE) {

814:     function setWithdrawalDelay(uint256 newDelay) external onlyRole(MANAGER_ROLE) {

822:     function enableWhitelist() external onlyRole(MANAGER_ROLE) {

830:     function disableWhitelist() external onlyRole(MANAGER_ROLE) {

839:     function addToWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

852:     function removeFromWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

885:     function pauseStaking() external onlyRole(MANAGER_ROLE) {

893:     function unpauseStaking() external onlyRole(MANAGER_ROLE) {

901:     function pauseWithdrawal() external onlyRole(MANAGER_ROLE) {

909:     function unpauseWithdrawal() external onlyRole(MANAGER_ROLE) {

919:     function cancelWithdrawal(address user, uint256 withdrawalId) external onlyRole(MANAGER_ROLE) whenNotPaused {

946:     function redelegateWithdrawnHYPE() external onlyRole(MANAGER_ROLE) whenNotPaused {

963:     function resetL1OperationsQueue() external onlyRole(MANAGER_ROLE) {

979:     function setUnstakeFeeRate(uint256 newRate) external onlyRole(MANAGER_ROLE) {

986:     function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {

994:     function withdrawFromSpot(uint64 amount) external onlyRole(OPERATOR_ROLE) {

1007:     function withdrawTokenFromSpot(uint64 tokenId, uint64 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

1028:     function rescueToken(address token, uint256 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

131:     function activateValidator(address validator) external whenNotPaused onlyRole(MANAGER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="GAS-13"></a>[GAS-13] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (13)*:
```solidity
File: ./src/OracleManager.sol

211:                     validOracleCount++;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

77:         for (uint256 i = 0; i < contracts.length; i++) {

114:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

110:         for (uint256 i = 0; i < length; i++) {

203:         for (uint256 i = 0; i < uniqueTokenCount; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

317:         for (uint256 i = 0; i < withdrawalIds.length; i++) {

688:         for (uint256 i = _withdrawalProcessingIndex; i < endIndex; i++) {

701:             processedCount++;

736:         for (uint256 i = _depositProcessingIndex; i < endIndex; i++) {

744:             processedCount++;

840:         for (uint256 i = 0; i < accounts.length; i++) {

853:         for (uint256 i = 0; i < accounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

378:                 count++;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="GAS-14"></a>[GAS-14] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (21)*:
```solidity
File: ./src/KHYPE.sol

27:     bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // Role allowed to mint new tokens

28:     bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); // Role allowed to burn tokens

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

37:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

38:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

29:     bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

30:     bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");

31:     bytes32 public constant PAUSE_ALL_ROLE = keccak256("PAUSE_ALL_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

32:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

46:     address public constant L1_HYPE_CONTRACT = 0x2222222222222222222222222222222222222222;

47:     L1Write public constant l1Write = L1Write(0x3333333333333333333333333333333333333333);

50:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

53:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

54:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

55:     bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

56:     bytes32 public constant SENTINEL_ROLE = keccak256("SENTINEL_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

38:     uint256 public constant BASIS_POINTS = 10000;

43:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

46:     bytes32 public constant ORACLE_MANAGER_ROLE = keccak256("ORACLE_MANAGER_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

29:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

34:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

37:     uint256 public constant MIN_UPDATE_INTERVAL = 1 hours;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="GAS-15"></a>[GAS-15] Splitting require() statements that use && saves gas

*Instances (2)*:
```solidity
File: ./src/StakingManager.sol

169:             require(_stakingLimit > _maxStakeAmount && _stakingLimit > _minStakeAmount, "Invalid staking limit");

780:             require(newStakingLimit > maxStakeAmount && newStakingLimit > minStakeAmount, "Invalid staking limit");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="GAS-16"></a>[GAS-16] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (9)*:
```solidity
File: ./src/PauserRegistry.sol

77:         for (uint256 i = 0; i < contracts.length; i++) {

114:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

110:         for (uint256 i = 0; i < length; i++) {

203:         for (uint256 i = 0; i < uniqueTokenCount; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

317:         for (uint256 i = 0; i < withdrawalIds.length; i++) {

688:         for (uint256 i = _withdrawalProcessingIndex; i < endIndex; i++) {

736:         for (uint256 i = _depositProcessingIndex; i < endIndex; i++) {

840:         for (uint256 i = 0; i < accounts.length; i++) {

853:         for (uint256 i = 0; i < accounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="GAS-17"></a>[GAS-17] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (41)*:
```solidity
File: ./src/OracleManager.sol

79:         require(_maxPerformanceBound > 0, "Invalid max performance bound");

154:         require(oracleCount > 0, "No oracles authorized");

189:                     if (timestamp > 0) emit OracleDataStale(oracle, validator, timestamp, block.timestamp);

291:         require(newBound > 0, "Invalid bound");

297:         require(newInterval > 0, "Invalid interval");

303:         require(newStaleness > 0, "Invalid staleness period");

315:         require(newMinimum > 0, "Minimum must be greater than zero");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingAccountant.sol

187:         require(exchangeRatio > 0, "Invalid exchange ratio");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

164:         require(_minStakeAmount > 0, "Invalid min stake amount");

165:         if (_maxStakeAmount > 0) {

168:         if (_stakingLimit > 0) {

227:         if (maxStakeAmount > 0) {

230:         if (stakingLimit > 0) {

262:         require(kHYPEAmount > 0, "Invalid amount");

304:         require(amount > 0, "No valid withdrawal request");

322:         if (totalAmount > 0) {

344:         require(validators.length > 0, "Empty arrays");

347:             require(amounts[i] > 0, "Invalid amount");

364:         require(amount > 0, "Invalid amount");

419:         if (roundUp && amount % 1e10 > 0) {

446:             if (amount > 0 && currentBuffer < target) {

462:             if (remainder > 0) {

516:         require(amount > 0, "Invalid withdrawal amount");

524:             if (amountFromBuffer > 0) {

564:         require(validators.length > 0, "Empty arrays");

779:         if (newStakingLimit > 0) {

792:         require(newMinStakeAmount > 0, "Invalid min stake amount");

800:         if (newMaxStakeAmount > 0) {

803:         if (stakingLimit > 0) {

921:         require(request.hypeAmount > 0, "No such withdrawal request");

947:         require(_cancelledWithdrawalAmount > 0, "No cancelled withdrawals");

1008:         require(amount > 0, "Invalid amount");

1029:         require(amount > 0, "Invalid amount");

1051:         require(amount > 0, "Invalid withdrawal amount");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

205:         require(validators.length > 0, "Empty arrays");

229:         require(withdrawalAmount > 0, "Invalid withdrawal amount");

254:         require(_validatorsWithPendingRebalance.length() > 0, "No pending requests");

255:         require(validators.length > 0, "Empty array");

281:         if (totalAmount > 0) {

413:         require(amount > 0, "Invalid reward amount");

431:         require(amount > 0, "Invalid slash amount");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Constants should be in CONSTANT_CASE | 1 |
| [NC-2](#NC-2) | `constant`s should be defined rather than using magic numbers | 4 |
| [NC-3](#NC-3) | Control structures do not follow the Solidity Style Guide | 3 |
| [NC-4](#NC-4) | Critical Changes Should Use Two-step Procedure | 2 |
| [NC-5](#NC-5) | Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function | 53 |
| [NC-6](#NC-6) | Events that mark critical parameter changes should contain both the old and the new value | 15 |
| [NC-7](#NC-7) | Function ordering does not follow the Solidity style guide | 7 |
| [NC-8](#NC-8) | Functions should not be longer than 50 lines | 99 |
| [NC-9](#NC-9) | Change int to int256 | 2 |
| [NC-10](#NC-10) | Interfaces should be defined in separate files from their usage | 1 |
| [NC-11](#NC-11) | Lack of checks in setters | 4 |
| [NC-12](#NC-12) | Missing Event for critical parameters change | 1 |
| [NC-13](#NC-13) | NatSpec is completely non-existent on functions that should have them | 20 |
| [NC-14](#NC-14) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 7 |
| [NC-15](#NC-15) | Constant state variables defined more than once | 10 |
| [NC-16](#NC-16) | Consider using named mappings | 11 |
| [NC-17](#NC-17) | `address`s shouldn't be hard-coded | 2 |
| [NC-18](#NC-18) | Adding a `return` statement when the function defines a named return variable, is redundant | 5 |
| [NC-19](#NC-19) | Avoid the use of sensitive terms | 22 |
| [NC-20](#NC-20) | Contract does not follow the Solidity style guide's suggested layout ordering | 7 |
| [NC-21](#NC-21) | TODO Left in the code | 2 |
| [NC-22](#NC-22) | Use Underscores for Number Literals (add an underscore every 3 digits) | 4 |
| [NC-23](#NC-23) | Internal and private variables and functions names should begin with an underscore | 2 |
| [NC-24](#NC-24) | Event is missing `indexed` fields | 1 |
| [NC-25](#NC-25) | `public` functions not called by the contract should be declared `external` instead | 10 |
| [NC-26](#NC-26) | Variables need not be initialized to zero | 18 |
### <a name="NC-1"></a>[NC-1] Constants should be in CONSTANT_CASE
For `constant` variable names, each word should use all capital letters, with underscores separating each word (CONSTANT_CASE)

*Instances (1)*:
```solidity
File: ./src/StakingManager.sol

47:     L1Write public constant l1Write = L1Write(0x3333333333333333333333333333333333333333);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-2"></a>[NC-2] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (4)*:
```solidity
File: ./src/OracleManager.sol

91:         MIN_UPDATE_INTERVAL = 24 hours;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingManager.sol

198:         unstakeFeeRate = 10;

199:         withdrawalDelay = 7 days;

980:         require(newRate <= 1000, "Fee rate too high"); // Max 10%

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-3"></a>[NC-3] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (3)*:
```solidity
File: ./src/OracleManager.sol

189:                     if (timestamp > 0) emit OracleDataStale(oracle, validator, timestamp, block.timestamp);

197:                 if (

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingManager.sol

569:             if (

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-4"></a>[NC-4] Critical Changes Should Use Two-step Procedure
The critical procedures should be two step process.

See similar findings in previous Code4rena contests for reference: <https://code4rena.com/reports/2022-06-illuminate/#2-critical-changes-should-use-two-step-procedure>

**Recommended Mitigation Steps**

Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (2)*:
```solidity
File: ./src/OracleManager.sol

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingManager.sol

986:     function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-5"></a>[NC-5] Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function

*Instances (53)*:
```solidity
File: ./src/PauserRegistry.sol

89:         require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

101:         require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

142:         require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

64:         require(manager != address(0), "Invalid manager address");

83:         require(manager != address(0), "Invalid manager address");

155:         require(index < _authorizedManagers.length(), "Index out of bounds");

164:         require(index < _uniqueTokens.length(), "Index out of bounds");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

161:         require(_treasury != address(0), "Invalid treasury address");

164:         require(_minStakeAmount > 0, "Invalid min stake amount");

169:             require(_stakingLimit > _maxStakeAmount && _stakingLimit > _minStakeAmount, "Invalid staking limit");

222:             require(isWhitelisted(msg.sender), "Address not whitelisted");

259:             require(isWhitelisted(msg.sender), "Address not whitelisted");

262:         require(kHYPEAmount > 0, "Invalid amount");

263:         require(kHYPE.balanceOf(msg.sender) >= kHYPEAmount, "Insufficient kHYPE balance");

305:         require(address(this).balance >= amount, "Insufficient contract balance");

311:         require(success, "Transfer failed");

323:             require(address(this).balance >= totalAmount, "Insufficient contract balance");

329:             require(success, "Transfer failed");

342:         require(msg.sender == address(validatorManager), "Only ValidatorManager");

343:         require(validators.length == amounts.length, "Length mismatch");

344:         require(validators.length > 0, "Empty arrays");

347:             require(amounts[i] > 0, "Invalid amount");

363:         require(msg.sender == address(validatorManager), "Only ValidatorManager");

364:         require(amount > 0, "Invalid amount");

391:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

424:         require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");

441:             require(amount % 1e10 == 0, "Amount must be divisible by 1e10");

488:             require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");

515:         require(validator != address(0), "Invalid validator address");

516:         require(amount > 0, "Invalid withdrawal amount");

562:         require(validators.length == amounts.length, "Length mismatch");

563:         require(validators.length == operationTypes.length, "Length mismatch");

564:         require(validators.length > 0, "Empty arrays");

690:             require(op.amount <= type(uint64).max, "Amount exceeds uint64 max");

738:             require(op.amount <= type(uint64).max, "Amount exceeds uint64 max");

780:             require(newStakingLimit > maxStakeAmount && newStakingLimit > minStakeAmount, "Invalid staking limit");

792:         require(newMinStakeAmount > 0, "Invalid min stake amount");

793:         require(newMinStakeAmount % 1e10 == 0, "Amount must be divisible by 1e10");

928:         require(kHYPE.balanceOf(address(this)) >= kHYPEAmount + kHYPEFee, "Insufficient kHYPE balance");

987:         require(newTreasury != address(0), "Invalid treasury address");

1008:         require(amount > 0, "Invalid amount");

1029:         require(amount > 0, "Invalid amount");

1050:         require(validator != address(0), "Invalid validator address");

1051:         require(amount > 0, "Invalid withdrawal amount");

1055:         require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

91:         require(_validatorIndexes.contains(validator), "Validator does not exist");

132:         require(validator != address(0), "Invalid validator address");

160:         require(exists, "Validator does not exist");

179:         require(exists, "Validator does not exist");

183:         require(!_validatorsWithPendingRebalance.contains(validator), "Validator has pending rebalance");

208:             require(validators[i] != address(0), "Invalid validator address");

228:         require(!_validatorsWithPendingRebalance.contains(validator), "Validator has pending rebalance");

232:         require(exists, "Validator does not exist");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="NC-6"></a>[NC-6] Events that mark critical parameter changes should contain both the old and the new value
This should especially be done if the new value is not required to be different from the old value

*Instances (15)*:
```solidity
File: ./src/OracleManager.sol

114:     function setOracleActive(address adapter, bool active) external whenNotPaused onlyRole(MANAGER_ROLE) {
             require(authorizedOracles.contains(adapter), "Oracle not authorized");
             activeOracles[adapter] = active;
             emit OracleActiveStateChanged(adapter, active);

290:     function setMaxPerformanceBound(uint256 newBound) external onlyRole(OPERATOR_ROLE) {
             require(newBound > 0, "Invalid bound");
             maxPerformanceBound = newBound;
             emit MaxPerformanceBoundUpdated(newBound);

302:     function setMaxOracleStaleness(uint256 newStaleness) external onlyRole(MANAGER_ROLE) {
             require(newStaleness > 0, "Invalid staleness period");
             MAX_ORACLE_STALENESS = newStaleness;
             emit MaxOracleStalenessUpdated(newStaleness);

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {
             sanityChecker = IValidatorSanityChecker(newChecker);
             emit SanityCheckerUpdated(newChecker);

314:     function setMinValidOracles(uint256 newMinimum) external onlyRole(MANAGER_ROLE) {
             require(newMinimum > 0, "Minimum must be greater than zero");
             MIN_VALID_ORACLES = newMinimum;
             emit MinValidOraclesUpdated(newMinimum);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingManager.sol

773:     function setTargetBuffer(uint256 newTargetBuffer) external onlyRole(MANAGER_ROLE) {
             targetBuffer = newTargetBuffer;
             emit TargetBufferUpdated(newTargetBuffer);

778:     function setStakingLimit(uint256 newStakingLimit) external onlyRole(MANAGER_ROLE) {
             if (newStakingLimit > 0) {
                 require(newStakingLimit > maxStakeAmount && newStakingLimit > minStakeAmount, "Invalid staking limit");
             }
             stakingLimit = newStakingLimit;
             emit StakingLimitUpdated(newStakingLimit);

791:     function setMinStakeAmount(uint256 newMinStakeAmount) external onlyRole(MANAGER_ROLE) {
             require(newMinStakeAmount > 0, "Invalid min stake amount");
             require(newMinStakeAmount % 1e10 == 0, "Amount must be divisible by 1e10");
     
             minStakeAmount = newMinStakeAmount;
             emit MinStakeAmountUpdated(newMinStakeAmount);

799:     function setMaxStakeAmount(uint256 newMaxStakeAmount) external onlyRole(MANAGER_ROLE) {
             if (newMaxStakeAmount > 0) {
                 require(newMaxStakeAmount > minStakeAmount, "Max stake must be greater than min");
             }
             if (stakingLimit > 0) {
                 require(newMaxStakeAmount <= stakingLimit, "Max stake must be less than limit");
             }
             maxStakeAmount = newMaxStakeAmount;
             emit MaxStakeAmountUpdated(newMaxStakeAmount);

814:     function setWithdrawalDelay(uint256 newDelay) external onlyRole(MANAGER_ROLE) {
             withdrawalDelay = newDelay;
             emit WithdrawalDelayUpdated(newDelay);

979:     function setUnstakeFeeRate(uint256 newRate) external onlyRole(MANAGER_ROLE) {
             require(newRate <= 1000, "Fee rate too high"); // Max 10%
             unstakeFeeRate = newRate;
             emit UnstakeFeeRateUpdated(newRate);

986:     function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
             require(newTreasury != address(0), "Invalid treasury address");
             address oldTreasury = treasury;
             treasury = newTreasury;
             emit TreasuryUpdated(oldTreasury, newTreasury);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

304:     function updateValidatorPerformance(
             address validator,
             uint256 balance,
             uint256 uptimeScore,
             uint256 speedScore,
             uint256 integrityScore,
             uint256 selfStakeScore
         ) external whenNotPaused onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {
             // Validate scores are within bounds
             require(
                 uptimeScore <= BASIS_POINTS &&
                     speedScore <= BASIS_POINTS &&
                     integrityScore <= BASIS_POINTS &&
                     selfStakeScore <= BASIS_POINTS,
                 "Score exceeds maximum"
             );
     
             uint256 index = _validatorIndexes.get(validator);
     
             // Update validator struct in one storage write
             _validators[index] = Validator({
                 balance: balance,
                 uptimeScore: uptimeScore,
                 speedScore: speedScore,
                 integrityScore: integrityScore,
                 selfStakeScore: selfStakeScore,
                 lastUpdateTime: block.timestamp,
                 active: _validators[index].active // Preserve active state
             });
     
             // Update performance report in one storage write
             validatorPerformance[validator] = PerformanceReport({
                 balance: balance,
                 uptimeScore: uptimeScore,
                 speedScore: speedScore,
                 integrityScore: integrityScore,
                 selfStakeScore: selfStakeScore,
                 timestamp: block.timestamp
             });
     
             emit ValidatorPerformanceUpdated(validator, block.timestamp, block.number);

447:     function setDelegation(
             address stakingManager,
             address validator
         ) external whenNotPaused onlyRole(MANAGER_ROLE) validatorActive(validator) {
             require(stakingManager != address(0), "Invalid staking manager");
             address oldDelegation = delegations[stakingManager];
             delegations[stakingManager] = validator;
     
             emit DelegationUpdated(stakingManager, oldDelegation, validator);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

81:     function updateValidatorMetrics(
            address validator,
            uint256 balance,
            uint256 uptime, // 0-10000 basis points
            uint256 speed, // 0-10000 basis points
            uint256 integrity, // 0-10000 basis points
            uint256 stake, // 0-10000 basis points
            uint256 reward,
            uint256 slashing
        ) external onlyRole(OPERATOR_ROLE) {
            require(validator != address(0), "Invalid validator");
            require(uptime <= BASIS_POINTS, "Uptime score exceeds BASIS_POINTS");
            require(speed <= BASIS_POINTS, "Speed score exceeds BASIS_POINTS");
            require(integrity <= BASIS_POINTS, "Integrity score exceeds BASIS_POINTS");
            require(stake <= BASIS_POINTS, "Stake score exceeds BASIS_POINTS");
    
            ValidatorMetrics memory metrics = validatorMetrics[validator];
            require(block.timestamp >= metrics.lastUpdateTime + MIN_UPDATE_INTERVAL, "Update too frequent");
    
            validatorMetrics[validator] = ValidatorMetrics({
                balance: balance,
                uptime: uptime,
                speed: speed,
                integrity: integrity,
                stake: stake,
                reward: reward,
                slashing: slashing,
                lastUpdateTime: block.timestamp
            });
    
            _validators.add(validator);
    
            emit MetricsUpdated(validator, balance, uptime, speed, integrity, stake, reward, slashing);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-7"></a>[NC-7] Function ordering does not follow the Solidity style guide
According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (7)*:
```solidity
File: ./src/KHYPE.sol

1: 
   Current order:
   public initialize
   external mint
   external burn
   public supportsInterface
   internal _update
   
   Suggested order:
   external mint
   external burn
   public initialize
   public supportsInterface
   internal _update

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

1: 
   Current order:
   public initialize
   external authorizeOracleAdapter
   external deauthorizeOracle
   external setOracleActive
   public isAuthorizedOracle
   public isActiveOracle
   external getAuthorizedOracleCount
   external getAuthorizedOracleAt
   external getAuthorizedOracles
   external generatePerformance
   external setMaxPerformanceBound
   external setMinUpdateInterval
   external setMaxOracleStaleness
   external setSanityChecker
   external setMinValidOracles
   
   Suggested order:
   external authorizeOracleAdapter
   external deauthorizeOracle
   external setOracleActive
   external getAuthorizedOracleCount
   external getAuthorizedOracleAt
   external getAuthorizedOracles
   external generatePerformance
   external setMaxPerformanceBound
   external setMinUpdateInterval
   external setMaxOracleStaleness
   external setSanityChecker
   external setMinValidOracles
   public initialize
   public isAuthorizedOracle
   public isActiveOracle

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

1: 
   Current order:
   public initialize
   external pauseContract
   external unpauseContract
   external emergencyPauseAll
   external authorizeContract
   external deauthorizeContract
   external isAuthorizedContract
   external getAuthorizedContracts
   external getAuthorizedContractCount
   
   Suggested order:
   external pauseContract
   external unpauseContract
   external emergencyPauseAll
   external authorizeContract
   external deauthorizeContract
   external isAuthorizedContract
   external getAuthorizedContracts
   external getAuthorizedContractCount
   public initialize

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

1: 
   Current order:
   public initialize
   external authorizeStakingManager
   external deauthorizeStakingManager
   external recordStake
   external recordClaim
   external isAuthorizedManager
   external getManagerToken
   external getAuthorizedManagerCount
   external getAuthorizedManagerAt
   external getUniqueTokenCount
   external getUniqueTokenAt
   external totalRewards
   external totalSlashing
   public kHYPEToHYPE
   public HYPEToKHYPE
   internal _getExchangeRatio
   
   Suggested order:
   external authorizeStakingManager
   external deauthorizeStakingManager
   external recordStake
   external recordClaim
   external isAuthorizedManager
   external getManagerToken
   external getAuthorizedManagerCount
   external getAuthorizedManagerAt
   external getUniqueTokenCount
   external getUniqueTokenAt
   external totalRewards
   external totalSlashing
   public initialize
   public kHYPEToHYPE
   public HYPEToKHYPE
   internal _getExchangeRatio

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

1: 
   Current order:
   public initialize
   public stake
   external queueWithdrawal
   external confirmWithdrawal
   external batchConfirmWithdrawals
   external processValidatorWithdrawals
   external processValidatorRedelegation
   internal _processConfirmation
   internal _convertTo8Decimals
   internal _distributeStake
   internal _withdrawFromValidator
   external queueL1Operations
   internal _queueL1Operation
   public processL1Operations
   internal _processL1Withdrawals
   internal _processL1Deposits
   external processL1Operations
   external withdrawalRequests
   external setTargetBuffer
   external setStakingLimit
   external setMinStakeAmount
   external setMaxStakeAmount
   external setWithdrawalDelay
   external enableWhitelist
   external disableWhitelist
   external addToWhitelist
   external removeFromWhitelist
   public isWhitelisted
   external whitelistLength
   external pauseStaking
   external unpauseStaking
   external pauseWithdrawal
   external unpauseWithdrawal
   external cancelWithdrawal
   external redelegateWithdrawnHYPE
   external resetL1OperationsQueue
   external setUnstakeFeeRate
   external setTreasury
   external withdrawFromSpot
   external withdrawTokenFromSpot
   external rescueToken
   external executeEmergencyWithdrawal
   
   Suggested order:
   external queueWithdrawal
   external confirmWithdrawal
   external batchConfirmWithdrawals
   external processValidatorWithdrawals
   external processValidatorRedelegation
   external queueL1Operations
   external processL1Operations
   external withdrawalRequests
   external setTargetBuffer
   external setStakingLimit
   external setMinStakeAmount
   external setMaxStakeAmount
   external setWithdrawalDelay
   external enableWhitelist
   external disableWhitelist
   external addToWhitelist
   external removeFromWhitelist
   external whitelistLength
   external pauseStaking
   external unpauseStaking
   external pauseWithdrawal
   external unpauseWithdrawal
   external cancelWithdrawal
   external redelegateWithdrawnHYPE
   external resetL1OperationsQueue
   external setUnstakeFeeRate
   external setTreasury
   external withdrawFromSpot
   external withdrawTokenFromSpot
   external rescueToken
   external executeEmergencyWithdrawal
   public initialize
   public stake
   public processL1Operations
   public isWhitelisted
   internal _processConfirmation
   internal _convertTo8Decimals
   internal _distributeStake
   internal _withdrawFromValidator
   internal _queueL1Operation
   internal _processL1Withdrawals
   internal _processL1Deposits

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

1: 
   Current order:
   external initialize
   external activateValidator
   external deactivateValidator
   external reactivateValidator
   external rebalanceWithdrawal
   internal _addRebalanceRequest
   external closeRebalanceRequests
   external hasPendingRebalance
   external updateValidatorPerformance
   external validatorScores
   external validatorLastUpdateTime
   external validatorBalance
   public validatorActiveState
   external activeValidatorsCount
   public validatorCount
   public validatorAt
   public validatorInfo
   external reportRewardEvent
   external reportSlashingEvent
   external setDelegation
   external getDelegation
   
   Suggested order:
   external initialize
   external activateValidator
   external deactivateValidator
   external reactivateValidator
   external rebalanceWithdrawal
   external closeRebalanceRequests
   external hasPendingRebalance
   external updateValidatorPerformance
   external validatorScores
   external validatorLastUpdateTime
   external validatorBalance
   external activeValidatorsCount
   external reportRewardEvent
   external reportSlashingEvent
   external setDelegation
   external getDelegation
   public validatorActiveState
   public validatorCount
   public validatorAt
   public validatorInfo
   internal _addRebalanceRequest

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultAdapter.sol

1: 
   Current order:
   external getPerformance
   external name
   external version
   public supportsInterface
   external getValidatorMetrics
   
   Suggested order:
   external getPerformance
   external name
   external version
   external getValidatorMetrics
   public supportsInterface

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

### <a name="NC-8"></a>[NC-8] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (99)*:
```solidity
File: ./src/KHYPE.sol

87:     function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {

96:     function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {

116:     function _update(address from, address to, uint256 value) internal virtual override whenNotPaused {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

98:     function authorizeOracleAdapter(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

108:     function deauthorizeOracle(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

114:     function setOracleActive(address adapter, bool active) external whenNotPaused onlyRole(MANAGER_ROLE) {

120:     function isAuthorizedOracle(address adapter) public view returns (bool) {

124:     function isActiveOracle(address adapter) public view returns (bool) {

128:     function getAuthorizedOracleCount() external view returns (uint256) {

132:     function getAuthorizedOracleAt(uint256 index) external view returns (address) {

136:     function getAuthorizedOracles() external view returns (address[] memory) {

142:     function generatePerformance(address validator) external whenNotPaused onlyRole(OPERATOR_ROLE) returns (bool) {

290:     function setMaxPerformanceBound(uint256 newBound) external onlyRole(OPERATOR_ROLE) {

296:     function setMinUpdateInterval(uint256 newInterval) external onlyRole(MANAGER_ROLE) {

302:     function setMaxOracleStaleness(uint256 newStaleness) external onlyRole(MANAGER_ROLE) {

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {

314:     function setMinValidOracles(uint256 newMinimum) external onlyRole(MANAGER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

88:     function pauseContract(address contractAddress) external onlyRole(PAUSER_ROLE) {

100:     function unpauseContract(address contractAddress) external onlyRole(UNPAUSER_ROLE) {

111:     function emergencyPauseAll() external onlyRole(PAUSE_ALL_ROLE) {

129:     function authorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

141:     function deauthorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

155:     function isAuthorizedContract(address contractAddress) external view returns (bool) {

163:     function getAuthorizedContracts() external view returns (address[] memory) {

171:     function getAuthorizedContractCount() external view returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

62:     function initialize(address admin, address manager, address _validatorManager) public initializer {

82:     function authorizeStakingManager(address manager, address kHYPEToken) external onlyRole(MANAGER_ROLE) {

99:     function deauthorizeStakingManager(address manager) external override onlyRole(DEFAULT_ADMIN_ROLE) {

128:     function recordStake(uint256 amount) external override onlyAuthorizedManager {

133:     function recordClaim(uint256 amount) external override onlyAuthorizedManager {

140:     function isAuthorizedManager(address manager) external view override returns (bool) {

144:     function getManagerToken(address manager) external view returns (address) {

150:     function getAuthorizedManagerCount() external view returns (uint256) {

154:     function getAuthorizedManagerAt(uint256 index) external view returns (address manager, address token) {

159:     function getUniqueTokenCount() external view returns (uint256) {

163:     function getUniqueTokenAt(uint256 index) external view returns (address) {

168:     function totalRewards() external view override returns (uint256) {

172:     function totalSlashing() external view override returns (uint256) {

181:     function kHYPEToHYPE(uint256 kHYPEAmount) public view override returns (uint256) {

185:     function HYPEToKHYPE(uint256 HYPEAmount) public view override returns (uint256) {

197:     function _getExchangeRatio() internal view returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

219:     function stake() public payable nonReentrant whenNotPaused whenStakingNotPaused {

256:     function queueWithdrawal(uint256 kHYPEAmount) external nonReentrant whenNotPaused whenWithdrawalNotPaused {

302:     function confirmWithdrawal(uint256 withdrawalId) external nonReentrant whenNotPaused {

314:     function batchConfirmWithdrawals(uint256[] calldata withdrawalIds) external nonReentrant whenNotPaused {

362:     function processValidatorRedelegation(uint256 amount) external nonReentrant whenNotPaused {

378:     function _processConfirmation(address user, uint256 withdrawalId) internal returns (uint256) {

415:     function _convertTo8Decimals(uint256 amount, bool roundUp) internal pure returns (uint256 truncatedAmount) {

434:     function _distributeStake(uint256 amount, OperationType operationType) internal {

514:     function _withdrawFromValidator(address validator, uint256 amount, OperationType operationType) internal {

601:     function _queueL1Operation(address validator, uint256 amount, OperationType operationType) internal {

627:     function processL1Operations(uint256 batchSize) public onlyRole(OPERATOR_ROLE) whenNotPaused {

673:     function _processL1Withdrawals(uint256 batchSize) internal returns (uint256) {

721:     function _processL1Deposits(uint256 batchSize) internal returns (uint256) {

767:     function withdrawalRequests(address user, uint256 id) external view returns (WithdrawalRequest memory) {

773:     function setTargetBuffer(uint256 newTargetBuffer) external onlyRole(MANAGER_ROLE) {

778:     function setStakingLimit(uint256 newStakingLimit) external onlyRole(MANAGER_ROLE) {

791:     function setMinStakeAmount(uint256 newMinStakeAmount) external onlyRole(MANAGER_ROLE) {

799:     function setMaxStakeAmount(uint256 newMaxStakeAmount) external onlyRole(MANAGER_ROLE) {

814:     function setWithdrawalDelay(uint256 newDelay) external onlyRole(MANAGER_ROLE) {

822:     function enableWhitelist() external onlyRole(MANAGER_ROLE) {

830:     function disableWhitelist() external onlyRole(MANAGER_ROLE) {

839:     function addToWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

852:     function removeFromWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

870:     function isWhitelisted(address account) public view returns (bool) {

878:     function whitelistLength() external view returns (uint256) {

885:     function pauseStaking() external onlyRole(MANAGER_ROLE) {

893:     function unpauseStaking() external onlyRole(MANAGER_ROLE) {

901:     function pauseWithdrawal() external onlyRole(MANAGER_ROLE) {

909:     function unpauseWithdrawal() external onlyRole(MANAGER_ROLE) {

919:     function cancelWithdrawal(address user, uint256 withdrawalId) external onlyRole(MANAGER_ROLE) whenNotPaused {

946:     function redelegateWithdrawnHYPE() external onlyRole(MANAGER_ROLE) whenNotPaused {

963:     function resetL1OperationsQueue() external onlyRole(MANAGER_ROLE) {

979:     function setUnstakeFeeRate(uint256 newRate) external onlyRole(MANAGER_ROLE) {

986:     function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {

994:     function withdrawFromSpot(uint64 amount) external onlyRole(OPERATOR_ROLE) {

1007:     function withdrawTokenFromSpot(uint64 tokenId, uint64 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

1028:     function rescueToken(address token, uint256 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

109:     function initialize(address admin, address manager, address _oracle, address _pauserRegistry) external initializer {

131:     function activateValidator(address validator) external whenNotPaused onlyRole(MANAGER_ROLE) {

155:     function deactivateValidator(address validator) external whenNotPaused nonReentrant validatorExists(validator) {

227:     function _addRebalanceRequest(address staking, address validator, uint256 withdrawalAmount) internal {

291:     function hasPendingRebalance(address validator) external view returns (bool) {

361:     function validatorLastUpdateTime(address validator) external view validatorExists(validator) returns (uint256) {

365:     function validatorBalance(address validator) external view validatorExists(validator) returns (uint256) {

369:     function validatorActiveState(address validator) public view validatorExists(validator) returns (bool) {

373:     function activeValidatorsCount() external view returns (uint256) {

387:     function validatorCount() public view returns (uint256) {

391:     function validatorAt(uint256 index) public view returns (address validator, Validator memory data) {

400:     function validatorInfo(address validator) public view validatorExists(validator) returns (Validator memory) {

463:     function getDelegation(address stakingManager) external view returns (address) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultAdapter.sol

45:     function name() external pure override returns (string memory) {

49:     function version() external pure override returns (string memory) {

55:     function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

152:     function getValidators() external view returns (address[] memory) {

159:     function hasMetrics(address validator) external view returns (bool) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

```solidity
File: ./src/oracles/IOracleAdapter.sol

43:     function name() external view returns (string memory);

49:     function version() external view returns (string memory);

56:     function supportsInterface(bytes4 interfaceId) external view returns (bool);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/IOracleAdapter.sol)

### <a name="NC-9"></a>[NC-9] Change int to int256
Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (2)*:
```solidity
File: ./src/KHYPE.sol

27:     bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // Role allowed to mint new tokens

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

219:             } // Single increment point at the end of the loop

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

### <a name="NC-10"></a>[NC-10] Interfaces should be defined in separate files from their usage
The interfaces below should be defined in separate files, so that it's easier for future projects to import them, and to avoid duplication later on if they need to be used elsewhere in the project

*Instances (1)*:
```solidity
File: ./src/oracles/DefaultAdapter.sol

64: interface IDefaultOracle {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

### <a name="NC-11"></a>[NC-11] Lack of checks in setters
Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (4)*:
```solidity
File: ./src/OracleManager.sol

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {
             sanityChecker = IValidatorSanityChecker(newChecker);
             emit SanityCheckerUpdated(newChecker);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingManager.sol

773:     function setTargetBuffer(uint256 newTargetBuffer) external onlyRole(MANAGER_ROLE) {
             targetBuffer = newTargetBuffer;
             emit TargetBufferUpdated(newTargetBuffer);

814:     function setWithdrawalDelay(uint256 newDelay) external onlyRole(MANAGER_ROLE) {
             withdrawalDelay = newDelay;
             emit WithdrawalDelayUpdated(newDelay);

963:     function resetL1OperationsQueue() external onlyRole(MANAGER_ROLE) {
             uint256 withdrawalsLength = _pendingWithdrawals.length;
             uint256 depositsLength = _pendingDeposits.length;
     
             delete _pendingWithdrawals;
             delete _pendingDeposits;
             _withdrawalProcessingIndex = 0;
             _depositProcessingIndex = 0;
     
             emit L1OperationsQueueReset(withdrawalsLength + depositsLength);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-12"></a>[NC-12] Missing Event for critical parameters change
Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (1)*:
```solidity
File: ./src/OracleManager.sol

296:     function setMinUpdateInterval(uint256 newInterval) external onlyRole(MANAGER_ROLE) {
             require(newInterval > 0, "Invalid interval");
             MIN_UPDATE_INTERVAL = newInterval;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

### <a name="NC-13"></a>[NC-13] NatSpec is completely non-existent on functions that should have them
Public and external functions that aren't view or pure should have NatSpec comments

*Instances (20)*:
```solidity
File: ./src/OracleManager.sol

67:     function initialize(

98:     function authorizeOracleAdapter(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

108:     function deauthorizeOracle(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

114:     function setOracleActive(address adapter, bool active) external whenNotPaused onlyRole(MANAGER_ROLE) {

142:     function generatePerformance(address validator) external whenNotPaused onlyRole(OPERATOR_ROLE) returns (bool) {

290:     function setMaxPerformanceBound(uint256 newBound) external onlyRole(OPERATOR_ROLE) {

296:     function setMinUpdateInterval(uint256 newInterval) external onlyRole(MANAGER_ROLE) {

302:     function setMaxOracleStaleness(uint256 newStaleness) external onlyRole(MANAGER_ROLE) {

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {

314:     function setMinValidOracles(uint256 newMinimum) external onlyRole(MANAGER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingAccountant.sol

128:     function recordStake(uint256 amount) external override onlyAuthorizedManager {

133:     function recordClaim(uint256 amount) external override onlyAuthorizedManager {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

256:     function queueWithdrawal(uint256 kHYPEAmount) external nonReentrant whenNotPaused whenWithdrawalNotPaused {

314:     function batchConfirmWithdrawals(uint256[] calldata withdrawalIds) external nonReentrant whenNotPaused {

760:     function processL1Operations() external {

773:     function setTargetBuffer(uint256 newTargetBuffer) external onlyRole(MANAGER_ROLE) {

778:     function setStakingLimit(uint256 newStakingLimit) external onlyRole(MANAGER_ROLE) {

799:     function setMaxStakeAmount(uint256 newMaxStakeAmount) external onlyRole(MANAGER_ROLE) {

986:     function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {

994:     function withdrawFromSpot(uint64 amount) external onlyRole(OPERATOR_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-14"></a>[NC-14] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (7)*:
```solidity
File: ./src/StakingAccountant.sol

50:         require(_authorizedManagers.contains(msg.sender), "Not authorized");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

222:             require(isWhitelisted(msg.sender), "Address not whitelisted");

259:             require(isWhitelisted(msg.sender), "Address not whitelisted");

263:         require(kHYPE.balanceOf(msg.sender) >= kHYPEAmount, "Insufficient kHYPE balance");

342:         require(msg.sender == address(validatorManager), "Only ValidatorManager");

363:         require(msg.sender == address(validatorManager), "Only ValidatorManager");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

157:         require(hasRole(MANAGER_ROLE, msg.sender), "Not authorized");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="NC-15"></a>[NC-15] Constant state variables defined more than once
Rather than redefining state variable constant, consider using a library to store all constants as this will prevent data redundancy

*Instances (10)*:
```solidity
File: ./src/OracleManager.sol

37:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

38:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/StakingAccountant.sol

32:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

50:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

53:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

54:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

38:     uint256 public constant BASIS_POINTS = 10000;

43:     bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

29:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

34:     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-16"></a>[NC-16] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (11)*:
```solidity
File: ./src/OracleManager.sol

52:     mapping(address => uint256) public lastValidatorUpdate;

56:     mapping(address => bool) private activeOracles;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

34:     mapping(address => bool) public isPaused;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingManager.sol

90:     mapping(address => uint256) public nextWithdrawalId;

96:     mapping(address => mapping(uint256 => WithdrawalRequest)) private _withdrawalRequests;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

60:     mapping(address => address) public delegations;

63:     mapping(address => RebalanceRequest) public validatorRebalanceRequests;

66:     mapping(address => PerformanceReport) public validatorPerformance;

69:     mapping(address => uint256) public validatorSlashing;

72:     mapping(address => uint256) public validatorRewards;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

40:     mapping(address => ValidatorMetrics) public validatorMetrics;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-17"></a>[NC-17] `address`s shouldn't be hard-coded
It is often better to declare `address`es as `immutable`, and assign them via constructor arguments. This allows the code to remain the same across deployments on different networks, and avoids recompilation when addresses need to change.

*Instances (2)*:
```solidity
File: ./src/StakingManager.sol

46:     address public constant L1_HYPE_CONTRACT = 0x2222222222222222222222222222222222222222;

47:     L1Write public constant l1Write = L1Write(0x3333333333333333333333333333333333333333);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-18"></a>[NC-18] Adding a `return` statement when the function defines a named return variable, is redundant

*Instances (5)*:
```solidity
File: ./src/StakingManager.sol

409:     /**
          * @notice Converts amount from 18 decimals to 8 decimals for L1 operations
          * @param amount Amount in 18 decimals
          * @param roundUp Whether to round up (for withdrawals) or down (for deposits)
          * @return truncatedAmount Amount in 8 decimals
          */
         function _convertTo8Decimals(uint256 amount, bool roundUp) internal pure returns (uint256 truncatedAmount) {
             truncatedAmount = amount / 1e10;
     
             // For withdrawals, round up to ensure users get at least the requested amount
             if (roundUp && amount % 1e10 > 0) {
                 truncatedAmount += 1;
             }
     
             // Add check for uint64 overflow
             require(truncatedAmount <= type(uint64).max, "Amount exceeds uint64 max");
     
             return truncatedAmount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

349:     function validatorScores(
             address validator
         )
             external
             view
             validatorExists(validator)
             returns (uint256 uptimeScore, uint256 speedScore, uint256 integrityScore, uint256 selfStakeScore)
         {
             Validator memory val = _validators[_validatorIndexes.get(validator)];
             return (val.uptimeScore, val.speedScore, val.integrityScore, val.selfStakeScore);

391:     function validatorAt(uint256 index) public view returns (address validator, Validator memory data) {
             uint256 length = _validators.length;
             require(index < length, "Index out of bounds");
     
             (validator, ) = _validatorIndexes.at(index);
             data = _validators[index];
             return (validator, data);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultAdapter.sol

24:     function getPerformance(
            address validator
        )
            external
            view
            override
            returns (
                uint256 balance,
                uint256 uptimeScore,
                uint256 speedScore,
                uint256 integrityScore,
                uint256 selfStakeScore,
                uint256 rewardAmount,
                uint256 slashAmount,
                uint256 timestamp
            )
        {
            // Read data directly from external oracle - no conversion needed
            return IDefaultOracle(defaultOracle).getValidatorMetrics(validator);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultAdapter.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

116:     /**
          * @notice Get metrics for a validator
          * @param validator Address of the validator
          */
         function getValidatorMetrics(
             address validator
         )
             external
             view
             returns (
                 uint256 balance,
                 uint256 uptime,
                 uint256 speed,
                 uint256 integrity,
                 uint256 stake,
                 uint256 reward,
                 uint256 slashing,
                 uint256 timestamp
             )
         {
             ValidatorMetrics memory metrics = validatorMetrics[validator];
             return (

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-19"></a>[NC-19] Avoid the use of sensitive terms
Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (22)*:
```solidity
File: ./src/StakingManager.sol

87:     bool public whitelistEnabled;

97:     EnumerableSet.AddressSet private _whitelist;

221:         if (whitelistEnabled) {

222:             require(isWhitelisted(msg.sender), "Address not whitelisted");

258:         if (whitelistEnabled) {

259:             require(isWhitelisted(msg.sender), "Address not whitelisted");

822:     function enableWhitelist() external onlyRole(MANAGER_ROLE) {

823:         whitelistEnabled = true;

824:         emit WhitelistEnabled();

830:     function disableWhitelist() external onlyRole(MANAGER_ROLE) {

831:         whitelistEnabled = false;

832:         emit WhitelistDisabled();

839:     function addToWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

842:             _whitelist.add(accounts[i]);

843:             emit AddressWhitelisted(accounts[i]);

852:     function removeFromWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

855:             bool removed = _whitelist.remove(accounts[i]);

859:                 emit AddressRemovedFromWhitelist(accounts[i]);

870:     function isWhitelisted(address account) public view returns (bool) {

871:         return _whitelist.contains(account);

878:     function whitelistLength() external view returns (uint256) {

879:         return _whitelist.length();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="NC-20"></a>[NC-20] Contract does not follow the Solidity style guide's suggested layout ordering
The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be:

1) Type declarations
2) State variables
3) Events
4) Modifiers
5) Functions

However, the contract(s) below do not follow this ordering

*Instances (7)*:
```solidity
File: ./src/KHYPE.sol

1: 
   Current order:
   FunctionDefinition.constructor
   VariableDeclaration.pauserRegistry
   VariableDeclaration.MINTER_ROLE
   VariableDeclaration.BURNER_ROLE
   ModifierDefinition.whenNotPaused
   FunctionDefinition.initialize
   FunctionDefinition.mint
   FunctionDefinition.burn
   FunctionDefinition.supportsInterface
   FunctionDefinition._update
   
   Suggested order:
   VariableDeclaration.pauserRegistry
   VariableDeclaration.MINTER_ROLE
   VariableDeclaration.BURNER_ROLE
   ModifierDefinition.whenNotPaused
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.mint
   FunctionDefinition.burn
   FunctionDefinition.supportsInterface
   FunctionDefinition._update

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

1: 
   Current order:
   FunctionDefinition.constructor
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.OPERATOR_ROLE
   VariableDeclaration.pauserRegistry
   VariableDeclaration.validatorManager
   VariableDeclaration.sanityChecker
   VariableDeclaration.maxPerformanceBound
   VariableDeclaration.MIN_UPDATE_INTERVAL
   VariableDeclaration.MAX_ORACLE_STALENESS
   VariableDeclaration.MIN_VALID_ORACLES
   VariableDeclaration.lastValidatorUpdate
   VariableDeclaration.authorizedOracles
   VariableDeclaration.activeOracles
   ModifierDefinition.whenNotPaused
   FunctionDefinition.initialize
   FunctionDefinition.authorizeOracleAdapter
   FunctionDefinition.deauthorizeOracle
   FunctionDefinition.setOracleActive
   FunctionDefinition.isAuthorizedOracle
   FunctionDefinition.isActiveOracle
   FunctionDefinition.getAuthorizedOracleCount
   FunctionDefinition.getAuthorizedOracleAt
   FunctionDefinition.getAuthorizedOracles
   FunctionDefinition.generatePerformance
   FunctionDefinition.setMaxPerformanceBound
   FunctionDefinition.setMinUpdateInterval
   FunctionDefinition.setMaxOracleStaleness
   FunctionDefinition.setSanityChecker
   FunctionDefinition.setMinValidOracles
   
   Suggested order:
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.OPERATOR_ROLE
   VariableDeclaration.pauserRegistry
   VariableDeclaration.validatorManager
   VariableDeclaration.sanityChecker
   VariableDeclaration.maxPerformanceBound
   VariableDeclaration.MIN_UPDATE_INTERVAL
   VariableDeclaration.MAX_ORACLE_STALENESS
   VariableDeclaration.MIN_VALID_ORACLES
   VariableDeclaration.lastValidatorUpdate
   VariableDeclaration.authorizedOracles
   VariableDeclaration.activeOracles
   ModifierDefinition.whenNotPaused
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.authorizeOracleAdapter
   FunctionDefinition.deauthorizeOracle
   FunctionDefinition.setOracleActive
   FunctionDefinition.isAuthorizedOracle
   FunctionDefinition.isActiveOracle
   FunctionDefinition.getAuthorizedOracleCount
   FunctionDefinition.getAuthorizedOracleAt
   FunctionDefinition.getAuthorizedOracles
   FunctionDefinition.generatePerformance
   FunctionDefinition.setMaxPerformanceBound
   FunctionDefinition.setMinUpdateInterval
   FunctionDefinition.setMaxOracleStaleness
   FunctionDefinition.setSanityChecker
   FunctionDefinition.setMinValidOracles

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

1: 
   Current order:
   FunctionDefinition.constructor
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.PAUSER_ROLE
   VariableDeclaration.UNPAUSER_ROLE
   VariableDeclaration.PAUSE_ALL_ROLE
   VariableDeclaration.isPaused
   VariableDeclaration._authorizedContracts
   FunctionDefinition.initialize
   FunctionDefinition.pauseContract
   FunctionDefinition.unpauseContract
   FunctionDefinition.emergencyPauseAll
   FunctionDefinition.authorizeContract
   FunctionDefinition.deauthorizeContract
   FunctionDefinition.isAuthorizedContract
   FunctionDefinition.getAuthorizedContracts
   FunctionDefinition.getAuthorizedContractCount
   
   Suggested order:
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.PAUSER_ROLE
   VariableDeclaration.UNPAUSER_ROLE
   VariableDeclaration.PAUSE_ALL_ROLE
   VariableDeclaration.isPaused
   VariableDeclaration._authorizedContracts
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.pauseContract
   FunctionDefinition.unpauseContract
   FunctionDefinition.emergencyPauseAll
   FunctionDefinition.authorizeContract
   FunctionDefinition.deauthorizeContract
   FunctionDefinition.isAuthorizedContract
   FunctionDefinition.getAuthorizedContracts
   FunctionDefinition.getAuthorizedContractCount

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

1: 
   Current order:
   UsingForDirective.EnumerableMap.AddressToAddressMap
   UsingForDirective.EnumerableSet.AddressSet
   FunctionDefinition.constructor
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.validatorManager
   VariableDeclaration.totalStaked
   VariableDeclaration.totalClaimed
   VariableDeclaration._authorizedManagers
   VariableDeclaration._uniqueTokens
   ModifierDefinition.onlyAuthorizedManager
   FunctionDefinition.initialize
   FunctionDefinition.authorizeStakingManager
   FunctionDefinition.deauthorizeStakingManager
   FunctionDefinition.recordStake
   FunctionDefinition.recordClaim
   FunctionDefinition.isAuthorizedManager
   FunctionDefinition.getManagerToken
   FunctionDefinition.getAuthorizedManagerCount
   FunctionDefinition.getAuthorizedManagerAt
   FunctionDefinition.getUniqueTokenCount
   FunctionDefinition.getUniqueTokenAt
   FunctionDefinition.totalRewards
   FunctionDefinition.totalSlashing
   FunctionDefinition.kHYPEToHYPE
   FunctionDefinition.HYPEToKHYPE
   FunctionDefinition._getExchangeRatio
   
   Suggested order:
   UsingForDirective.EnumerableMap.AddressToAddressMap
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.validatorManager
   VariableDeclaration.totalStaked
   VariableDeclaration.totalClaimed
   VariableDeclaration._authorizedManagers
   VariableDeclaration._uniqueTokens
   ModifierDefinition.onlyAuthorizedManager
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.authorizeStakingManager
   FunctionDefinition.deauthorizeStakingManager
   FunctionDefinition.recordStake
   FunctionDefinition.recordClaim
   FunctionDefinition.isAuthorizedManager
   FunctionDefinition.getManagerToken
   FunctionDefinition.getAuthorizedManagerCount
   FunctionDefinition.getAuthorizedManagerAt
   FunctionDefinition.getUniqueTokenCount
   FunctionDefinition.getUniqueTokenAt
   FunctionDefinition.totalRewards
   FunctionDefinition.totalSlashing
   FunctionDefinition.kHYPEToHYPE
   FunctionDefinition.HYPEToKHYPE
   FunctionDefinition._getExchangeRatio

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

1: 
   Current order:
   FunctionDefinition.constructor
   UsingForDirective.Math
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.IERC20
   VariableDeclaration.L1_HYPE_CONTRACT
   VariableDeclaration.l1Write
   VariableDeclaration.BASIS_POINTS
   VariableDeclaration.OPERATOR_ROLE
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.TREASURY_ROLE
   VariableDeclaration.SENTINEL_ROLE
   VariableDeclaration.validatorManager
   VariableDeclaration.pauserRegistry
   VariableDeclaration.stakingAccountant
   VariableDeclaration.kHYPE
   VariableDeclaration.treasury
   VariableDeclaration.HYPE_TOKEN_ID
   VariableDeclaration.totalStaked
   VariableDeclaration.totalClaimed
   VariableDeclaration.totalQueuedWithdrawals
   VariableDeclaration.hypeBuffer
   VariableDeclaration.targetBuffer
   VariableDeclaration.stakingLimit
   VariableDeclaration.minStakeAmount
   VariableDeclaration.maxStakeAmount
   VariableDeclaration.withdrawalDelay
   VariableDeclaration.unstakeFeeRate
   VariableDeclaration.stakingPaused
   VariableDeclaration.withdrawalPaused
   VariableDeclaration.whitelistEnabled
   VariableDeclaration.nextWithdrawalId
   VariableDeclaration._cancelledWithdrawalAmount
   VariableDeclaration._withdrawalRequests
   VariableDeclaration._whitelist
   VariableDeclaration._pendingWithdrawals
   VariableDeclaration._pendingDeposits
   VariableDeclaration._withdrawalProcessingIndex
   VariableDeclaration._depositProcessingIndex
   ModifierDefinition.whenNotPaused
   ModifierDefinition.whenStakingNotPaused
   ModifierDefinition.whenWithdrawalNotPaused
   FunctionDefinition.initialize
   FunctionDefinition.receive
   FunctionDefinition.stake
   FunctionDefinition.queueWithdrawal
   FunctionDefinition.confirmWithdrawal
   FunctionDefinition.batchConfirmWithdrawals
   FunctionDefinition.processValidatorWithdrawals
   FunctionDefinition.processValidatorRedelegation
   FunctionDefinition._processConfirmation
   FunctionDefinition._convertTo8Decimals
   FunctionDefinition._distributeStake
   FunctionDefinition._withdrawFromValidator
   FunctionDefinition.queueL1Operations
   FunctionDefinition._queueL1Operation
   FunctionDefinition.processL1Operations
   FunctionDefinition._processL1Withdrawals
   FunctionDefinition._processL1Deposits
   FunctionDefinition.processL1Operations
   FunctionDefinition.withdrawalRequests
   FunctionDefinition.setTargetBuffer
   FunctionDefinition.setStakingLimit
   FunctionDefinition.setMinStakeAmount
   FunctionDefinition.setMaxStakeAmount
   FunctionDefinition.setWithdrawalDelay
   FunctionDefinition.enableWhitelist
   FunctionDefinition.disableWhitelist
   FunctionDefinition.addToWhitelist
   FunctionDefinition.removeFromWhitelist
   FunctionDefinition.isWhitelisted
   FunctionDefinition.whitelistLength
   FunctionDefinition.pauseStaking
   FunctionDefinition.unpauseStaking
   FunctionDefinition.pauseWithdrawal
   FunctionDefinition.unpauseWithdrawal
   FunctionDefinition.cancelWithdrawal
   FunctionDefinition.redelegateWithdrawnHYPE
   FunctionDefinition.resetL1OperationsQueue
   FunctionDefinition.setUnstakeFeeRate
   FunctionDefinition.setTreasury
   FunctionDefinition.withdrawFromSpot
   FunctionDefinition.withdrawTokenFromSpot
   FunctionDefinition.rescueToken
   FunctionDefinition.executeEmergencyWithdrawal
   
   Suggested order:
   UsingForDirective.Math
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.IERC20
   VariableDeclaration.L1_HYPE_CONTRACT
   VariableDeclaration.l1Write
   VariableDeclaration.BASIS_POINTS
   VariableDeclaration.OPERATOR_ROLE
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.TREASURY_ROLE
   VariableDeclaration.SENTINEL_ROLE
   VariableDeclaration.validatorManager
   VariableDeclaration.pauserRegistry
   VariableDeclaration.stakingAccountant
   VariableDeclaration.kHYPE
   VariableDeclaration.treasury
   VariableDeclaration.HYPE_TOKEN_ID
   VariableDeclaration.totalStaked
   VariableDeclaration.totalClaimed
   VariableDeclaration.totalQueuedWithdrawals
   VariableDeclaration.hypeBuffer
   VariableDeclaration.targetBuffer
   VariableDeclaration.stakingLimit
   VariableDeclaration.minStakeAmount
   VariableDeclaration.maxStakeAmount
   VariableDeclaration.withdrawalDelay
   VariableDeclaration.unstakeFeeRate
   VariableDeclaration.stakingPaused
   VariableDeclaration.withdrawalPaused
   VariableDeclaration.whitelistEnabled
   VariableDeclaration.nextWithdrawalId
   VariableDeclaration._cancelledWithdrawalAmount
   VariableDeclaration._withdrawalRequests
   VariableDeclaration._whitelist
   VariableDeclaration._pendingWithdrawals
   VariableDeclaration._pendingDeposits
   VariableDeclaration._withdrawalProcessingIndex
   VariableDeclaration._depositProcessingIndex
   ModifierDefinition.whenNotPaused
   ModifierDefinition.whenStakingNotPaused
   ModifierDefinition.whenWithdrawalNotPaused
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.receive
   FunctionDefinition.stake
   FunctionDefinition.queueWithdrawal
   FunctionDefinition.confirmWithdrawal
   FunctionDefinition.batchConfirmWithdrawals
   FunctionDefinition.processValidatorWithdrawals
   FunctionDefinition.processValidatorRedelegation
   FunctionDefinition._processConfirmation
   FunctionDefinition._convertTo8Decimals
   FunctionDefinition._distributeStake
   FunctionDefinition._withdrawFromValidator
   FunctionDefinition.queueL1Operations
   FunctionDefinition._queueL1Operation
   FunctionDefinition.processL1Operations
   FunctionDefinition._processL1Withdrawals
   FunctionDefinition._processL1Deposits
   FunctionDefinition.processL1Operations
   FunctionDefinition.withdrawalRequests
   FunctionDefinition.setTargetBuffer
   FunctionDefinition.setStakingLimit
   FunctionDefinition.setMinStakeAmount
   FunctionDefinition.setMaxStakeAmount
   FunctionDefinition.setWithdrawalDelay
   FunctionDefinition.enableWhitelist
   FunctionDefinition.disableWhitelist
   FunctionDefinition.addToWhitelist
   FunctionDefinition.removeFromWhitelist
   FunctionDefinition.isWhitelisted
   FunctionDefinition.whitelistLength
   FunctionDefinition.pauseStaking
   FunctionDefinition.unpauseStaking
   FunctionDefinition.pauseWithdrawal
   FunctionDefinition.unpauseWithdrawal
   FunctionDefinition.cancelWithdrawal
   FunctionDefinition.redelegateWithdrawnHYPE
   FunctionDefinition.resetL1OperationsQueue
   FunctionDefinition.setUnstakeFeeRate
   FunctionDefinition.setTreasury
   FunctionDefinition.withdrawFromSpot
   FunctionDefinition.withdrawTokenFromSpot
   FunctionDefinition.rescueToken
   FunctionDefinition.executeEmergencyWithdrawal

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

1: 
   Current order:
   FunctionDefinition.constructor
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.EnumerableMap.UintToAddressMap
   UsingForDirective.EnumerableMap.AddressToUintMap
   VariableDeclaration.BASIS_POINTS
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.ORACLE_MANAGER_ROLE
   VariableDeclaration.pauserRegistry
   VariableDeclaration.totalSlashing
   VariableDeclaration.totalRewards
   VariableDeclaration.delegations
   VariableDeclaration.validatorRebalanceRequests
   VariableDeclaration.validatorPerformance
   VariableDeclaration.validatorSlashing
   VariableDeclaration.validatorRewards
   VariableDeclaration._validators
   VariableDeclaration._validatorIndexes
   VariableDeclaration._validatorsWithPendingRebalance
   ModifierDefinition.whenNotPaused
   ModifierDefinition.validatorExists
   ModifierDefinition.validatorActive
   FunctionDefinition.initialize
   FunctionDefinition.activateValidator
   FunctionDefinition.deactivateValidator
   FunctionDefinition.reactivateValidator
   FunctionDefinition.rebalanceWithdrawal
   FunctionDefinition._addRebalanceRequest
   FunctionDefinition.closeRebalanceRequests
   FunctionDefinition.hasPendingRebalance
   FunctionDefinition.updateValidatorPerformance
   FunctionDefinition.validatorScores
   FunctionDefinition.validatorLastUpdateTime
   FunctionDefinition.validatorBalance
   FunctionDefinition.validatorActiveState
   FunctionDefinition.activeValidatorsCount
   FunctionDefinition.validatorCount
   FunctionDefinition.validatorAt
   FunctionDefinition.validatorInfo
   FunctionDefinition.reportRewardEvent
   FunctionDefinition.reportSlashingEvent
   FunctionDefinition.setDelegation
   FunctionDefinition.getDelegation
   
   Suggested order:
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.EnumerableMap.UintToAddressMap
   UsingForDirective.EnumerableMap.AddressToUintMap
   VariableDeclaration.BASIS_POINTS
   VariableDeclaration.MANAGER_ROLE
   VariableDeclaration.ORACLE_MANAGER_ROLE
   VariableDeclaration.pauserRegistry
   VariableDeclaration.totalSlashing
   VariableDeclaration.totalRewards
   VariableDeclaration.delegations
   VariableDeclaration.validatorRebalanceRequests
   VariableDeclaration.validatorPerformance
   VariableDeclaration.validatorSlashing
   VariableDeclaration.validatorRewards
   VariableDeclaration._validators
   VariableDeclaration._validatorIndexes
   VariableDeclaration._validatorsWithPendingRebalance
   ModifierDefinition.whenNotPaused
   ModifierDefinition.validatorExists
   ModifierDefinition.validatorActive
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.activateValidator
   FunctionDefinition.deactivateValidator
   FunctionDefinition.reactivateValidator
   FunctionDefinition.rebalanceWithdrawal
   FunctionDefinition._addRebalanceRequest
   FunctionDefinition.closeRebalanceRequests
   FunctionDefinition.hasPendingRebalance
   FunctionDefinition.updateValidatorPerformance
   FunctionDefinition.validatorScores
   FunctionDefinition.validatorLastUpdateTime
   FunctionDefinition.validatorBalance
   FunctionDefinition.validatorActiveState
   FunctionDefinition.activeValidatorsCount
   FunctionDefinition.validatorCount
   FunctionDefinition.validatorAt
   FunctionDefinition.validatorInfo
   FunctionDefinition.reportRewardEvent
   FunctionDefinition.reportSlashingEvent
   FunctionDefinition.setDelegation
   FunctionDefinition.getDelegation

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

1: 
   Current order:
   UsingForDirective.EnumerableSet.AddressSet
   StructDefinition.ValidatorMetrics
   VariableDeclaration.BASIS_POINTS
   VariableDeclaration.OPERATOR_ROLE
   VariableDeclaration.MIN_UPDATE_INTERVAL
   VariableDeclaration.validatorMetrics
   VariableDeclaration._validators
   EventDefinition.MetricsUpdated
   FunctionDefinition.constructor
   FunctionDefinition.updateValidatorMetrics
   FunctionDefinition.getValidatorMetrics
   FunctionDefinition.getValidators
   FunctionDefinition.hasMetrics
   
   Suggested order:
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.BASIS_POINTS
   VariableDeclaration.OPERATOR_ROLE
   VariableDeclaration.MIN_UPDATE_INTERVAL
   VariableDeclaration.validatorMetrics
   VariableDeclaration._validators
   StructDefinition.ValidatorMetrics
   EventDefinition.MetricsUpdated
   FunctionDefinition.constructor
   FunctionDefinition.updateValidatorMetrics
   FunctionDefinition.getValidatorMetrics
   FunctionDefinition.getValidators
   FunctionDefinition.hasMetrics

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-21"></a>[NC-21] TODO Left in the code
TODOs may signal that a feature is missing or not ready for audit, consider resolving the issue and removing the TODO comment

*Instances (2)*:
```solidity
File: ./src/KHYPE.sol

88:         _mint(to, amount); // TODO update the logic with mirror token

97:         _burn(from, amount); // TODO update the logic with mirror token

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

### <a name="NC-22"></a>[NC-22] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (4)*:
```solidity
File: ./src/StakingManager.sol

50:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

980:         require(newRate <= 1000, "Fee rate too high"); // Max 10%

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

38:     uint256 public constant BASIS_POINTS = 10000;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

29:     uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-23"></a>[NC-23] Internal and private variables and functions names should begin with an underscore
According to the Solidity Style Guide, Non-`external` variable and function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*Instances (2)*:
```solidity
File: ./src/OracleManager.sol

55:     EnumerableSet.AddressSet private authorizedOracles;

56:     mapping(address => bool) private activeOracles;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

### <a name="NC-24"></a>[NC-24] Event is missing `indexed` fields
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (1)*:
```solidity
File: ./src/oracles/DefaultOracle.sol

47:     event MetricsUpdated(

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="NC-25"></a>[NC-25] `public` functions not called by the contract should be declared `external` instead

*Instances (10)*:
```solidity
File: ./src/KHYPE.sol

48:     function initialize(

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

67:     function initialize(

120:     function isAuthorizedOracle(address adapter) public view returns (bool) {

124:     function isActiveOracle(address adapter) public view returns (bool) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

49:     function initialize(

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

62:     function initialize(address admin, address manager, address _validatorManager) public initializer {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

139:     function initialize(

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

387:     function validatorCount() public view returns (uint256) {

391:     function validatorAt(uint256 index) public view returns (address validator, Validator memory data) {

400:     function validatorInfo(address validator) public view validatorExists(validator) returns (Validator memory) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="NC-26"></a>[NC-26] Variables need not be initialized to zero
The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (18)*:
```solidity
File: ./src/OracleManager.sol

167:         for (uint256 i = 0; i < oracleCount; ) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

77:         for (uint256 i = 0; i < contracts.length; i++) {

114:         for (uint256 i = 0; i < length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

110:         for (uint256 i = 0; i < length; i++) {

199:         uint256 totalKHYPESupply = 0;

203:         for (uint256 i = 0; i < uniqueTokenCount; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

315:         uint256 totalAmount = 0;

317:         for (uint256 i = 0; i < withdrawalIds.length; i++) {

346:         for (uint256 i = 0; i < validators.length; ) {

567:         for (uint256 i = 0; i < validators.length; ) {

637:         uint256 processedCount = 0;

685:         uint256 processedCount = 0;

733:         uint256 processedCount = 0;

840:         for (uint256 i = 0; i < accounts.length; i++) {

853:         for (uint256 i = 0; i < accounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

207:         for (uint256 i = 0; i < validators.length; ) {

257:         uint256 totalAmount = 0;

259:         for (uint256 i = 0; i < validators.length; ) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Some tokens may revert when zero value transfers are made | 1 |
| [L-2](#L-2) | Division by zero not prevented | 7 |
| [L-3](#L-3) | External call recipient may consume all transaction gas | 3 |
| [L-4](#L-4) | Initializers could be front-run | 20 |
| [L-5](#L-5) | Prevent accidentally burning tokens | 6 |
| [L-6](#L-6) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` | 7 |
| [L-7](#L-7) | Sweeping may break accounting if tokens with multiple addresses are used | 1 |
| [L-8](#L-8) | Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting | 6 |
| [L-9](#L-9) | Unsafe ERC20 operation(s) | 3 |
| [L-10](#L-10) | Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions | 23 |
| [L-11](#L-11) | Upgradeable contract not initialized | 49 |
### <a name="L-1"></a>[L-1] Some tokens may revert when zero value transfers are made
Example: https://github.com/d-xo/weird-erc20#revert-on-zero-value-transfers.

In spite of the fact that EIP-20 [states](https://github.com/ethereum/EIPs/blob/46b9b698815abbfa628cd1097311deee77dd45c5/EIPS/eip-20.md?plain=1#L116) that zero-valued transfers must be accepted, some tokens, such as LEND will revert if this is attempted, which may cause transactions that involve other tokens (such as batch operations) to fully revert. Consider skipping the transfer if the amount is zero, which will also save gas.

*Instances (1)*:
```solidity
File: ./src/StakingManager.sol

1035:         IERC20(token).safeTransfer(treasury, amount);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="L-2"></a>[L-2] Division by zero not prevented
The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (7)*:
```solidity
File: ./src/OracleManager.sol

226:         uint256 avgBalance = totalBalance / validOracleCount;

227:         uint256 avgUptimeScore = totalUptimeScore / validOracleCount;

228:         uint256 avgSpeedScore = totalSpeedScore / validOracleCount;

229:         uint256 avgIntegrityScore = totalIntegrityScore / validOracleCount;

230:         uint256 avgSelfStakeScore = totalSelfStakeScore / validOracleCount;

231:         uint256 avgRewardAmount = totalRewardAmount / validOracleCount;

232:         uint256 avgSlashAmount = totalSlashAmount / validOracleCount;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

### <a name="L-3"></a>[L-3] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (3)*:
```solidity
File: ./src/StakingManager.sol

310:         (bool success, ) = payable(msg.sender).call{value: amount}("");

328:             (bool success, ) = payable(msg.sender).call{value: totalAmount}("");

476:             (bool success, ) = payable(L1_HYPE_CONTRACT).call{value: amount}("");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="L-4"></a>[L-4] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (20)*:
```solidity
File: ./src/KHYPE.sol

48:     function initialize(

55:     ) public initializer {

63:         __ERC20_init(name, symbol);

64:         __ERC20Permit_init(name); // Initialize permit functionality for gasless transactions

65:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

67:     function initialize(

74:     ) public initializer {

75:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

49:     function initialize(

55:     ) public initializer {

63:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

62:     function initialize(address admin, address manager, address _validatorManager) public initializer {

67:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

139:     function initialize(

152:     ) public initializer {

178:         __AccessControlEnumerable_init();

179:         __ReentrancyGuard_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

109:     function initialize(address admin, address manager, address _oracle, address _pauserRegistry) external initializer {

115:         __AccessControlEnumerable_init();

116:         __ReentrancyGuard_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="L-5"></a>[L-5] Prevent accidentally burning tokens
Minting and burning tokens to address(0) prevention

*Instances (6)*:
```solidity
File: ./src/KHYPE.sol

59:         require(minter != address(0), "Invalid minter address");

60:         require(burner != address(0), "Invalid burner address");

73:         _grantRole(MINTER_ROLE, minter);

74:         _grantRole(BURNER_ROLE, burner);

88:         _mint(to, amount); // TODO update the logic with mirror token

97:         _burn(from, amount); // TODO update the logic with mirror token

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

### <a name="L-6"></a>[L-6] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`
The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

*Instances (7)*:
```solidity
File: ./src/KHYPE.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

2: pragma solidity ^0.8.20;

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="L-7"></a>[L-7] Sweeping may break accounting if tokens with multiple addresses are used
There have been [cases](https://blog.openzeppelin.com/compound-tusd-integration-issue-retrospective/) in the past where a token mistakenly had two addresses that could control its balance, and transfers using one address impacted the balance of the other. To protect against this potential scenario, sweep functions should ensure that the balance of the non-sweepable token does not change after the transfer of the swept tokens.

*Instances (1)*:
```solidity
File: ./src/StakingManager.sol

1028:     function rescueToken(address token, uint256 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="L-8"></a>[L-8] Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting
Downcasting from `uint256`/`int256` in Solidity does not revert on overflow. This can result in undesired exploitation or bugs, since developers usually assume that overflows raise errors. [OpenZeppelin's SafeCast library](https://docs.openzeppelin.com/contracts/3.x/api/utils#SafeCast) restores this intuition by reverting the transaction when such an operation overflows. Using this library eliminates an entire class of bugs, so it's recommended to use it always. Some exceptions are acceptable like with the classic `uint256(uint160(address(variable)))`

*Instances (6)*:
```solidity
File: ./src/StakingManager.sol

481:             l1Write.sendCDeposit(uint64(truncatedAmount));

491:             l1Write.sendCDeposit(uint64(truncatedAmount));

693:             l1Write.sendTokenDelegate(op.validator, uint64(op.amount), true);

697:                 l1Write.sendCWithdrawal(uint64(op.amount));

741:             l1Write.sendTokenDelegate(op.validator, uint64(op.amount), false);

1058:         l1Write.sendTokenDelegate(validator, uint64(truncatedAmount), true);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="L-9"></a>[L-9] Unsafe ERC20 operation(s)

*Instances (3)*:
```solidity
File: ./src/StakingManager.sol

277:         kHYPE.transferFrom(msg.sender, address(this), kHYPEAmount);

402:         kHYPE.transfer(treasury, kHYPEFee);

935:         kHYPE.transfer(user, kHYPEAmount + kHYPEFee);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

### <a name="L-10"></a>[L-10] Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions
See [this](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps) link for a description of this storage variable. While some contracts may not currently be sub-classed, adding the variable now protects against forgetting to add it in the future.

*Instances (23)*:
```solidity
File: ./src/KHYPE.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

15: contract KHYPE is ERC20PermitUpgradeable, AccessControlEnumerableUpgradeable {

109:     ) public view virtual override(AccessControlEnumerableUpgradeable) returns (bool) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

7: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

8: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

24: contract OracleManager is IOracleManager, Initializable, AccessControlEnumerableUpgradeable {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

16: contract PauserRegistry is IPauserRegistry, Initializable, AccessControlEnumerableUpgradeable {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

20: contract StakingAccountant is IStakingAccountant, Initializable, AccessControlEnumerableUpgradeable {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

8: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

29:     AccessControlEnumerableUpgradeable,

30:     ReentrancyGuardUpgradeable

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

4: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

5: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

6: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

21:     AccessControlEnumerableUpgradeable,

22:     ReentrancyGuardUpgradeable

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="L-11"></a>[L-11] Upgradeable contract not initialized
Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (49)*:
```solidity
File: ./src/KHYPE.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

15: contract KHYPE is ERC20PermitUpgradeable, AccessControlEnumerableUpgradeable {

18:         _disableInitializers();

48:     function initialize(

55:     ) public initializer {

63:         __ERC20_init(name, symbol);

64:         __ERC20Permit_init(name); // Initialize permit functionality for gasless transactions

65:         __AccessControlEnumerable_init();

109:     ) public view virtual override(AccessControlEnumerableUpgradeable) returns (bool) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

7: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

8: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

24: contract OracleManager is IOracleManager, Initializable, AccessControlEnumerableUpgradeable {

27:         _disableInitializers();

67:     function initialize(

74:     ) public initializer {

75:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

16: contract PauserRegistry is IPauserRegistry, Initializable, AccessControlEnumerableUpgradeable {

19:         _disableInitializers();

49:     function initialize(

55:     ) public initializer {

63:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

20: contract StakingAccountant is IStakingAccountant, Initializable, AccessControlEnumerableUpgradeable {

26:         _disableInitializers();

62:     function initialize(address admin, address manager, address _validatorManager) public initializer {

67:         __AccessControlEnumerable_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

6: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

7: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

8: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

29:     AccessControlEnumerableUpgradeable,

30:     ReentrancyGuardUpgradeable

34:         _disableInitializers();

139:     function initialize(

152:     ) public initializer {

178:         __AccessControlEnumerable_init();

179:         __ReentrancyGuard_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

4: import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

5: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

6: import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

21:     AccessControlEnumerableUpgradeable,

22:     ReentrancyGuardUpgradeable

26:         _disableInitializers();

109:     function initialize(address admin, address manager, address _oracle, address _pauserRegistry) external initializer {

115:         __AccessControlEnumerable_init();

116:         __ReentrancyGuard_init();

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | `block.number` means different things on different L2s | 1 |
| [M-2](#M-2) | Centralization Risk for trusted owners | 52 |
| [M-3](#M-3) | Direct `supportsInterface()` calls may cause caller to revert | 2 |
### <a name="M-1"></a>[M-1] `block.number` means different things on different L2s
On Optimism, `block.number` is the L2 block number, but on Arbitrum, it's the L1 block number, and `ArbSys(address(100)).arbBlockNumber()` must be used. Furthermore, L2 block numbers often occur much more frequently than L1 block numbers (any may even occur on a per-transaction basis), so using block numbers for timing results in inconsistencies, especially when voting is involved across multiple chains. As of version 4.9, OpenZeppelin has [modified](https://blog.openzeppelin.com/introducing-openzeppelin-contracts-v4.9#governor) their governor code to use a clock rather than block numbers, to avoid these sorts of issues, but this still requires that the project [implement](https://docs.openzeppelin.com/contracts/4.x/governance#token_2) a [clock](https://eips.ethereum.org/EIPS/eip-6372) for each L2.

*Instances (1)*:
```solidity
File: ./src/ValidatorManager.sol

344:         emit ValidatorPerformanceUpdated(validator, block.timestamp, block.number);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

### <a name="M-2"></a>[M-2] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (52)*:
```solidity
File: ./src/KHYPE.sol

87:     function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {

96:     function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

98:     function authorizeOracleAdapter(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

108:     function deauthorizeOracle(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {

114:     function setOracleActive(address adapter, bool active) external whenNotPaused onlyRole(MANAGER_ROLE) {

142:     function generatePerformance(address validator) external whenNotPaused onlyRole(OPERATOR_ROLE) returns (bool) {

290:     function setMaxPerformanceBound(uint256 newBound) external onlyRole(OPERATOR_ROLE) {

296:     function setMinUpdateInterval(uint256 newInterval) external onlyRole(MANAGER_ROLE) {

302:     function setMaxOracleStaleness(uint256 newStaleness) external onlyRole(MANAGER_ROLE) {

309:     function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {

314:     function setMinValidOracles(uint256 newMinimum) external onlyRole(MANAGER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

```solidity
File: ./src/PauserRegistry.sol

88:     function pauseContract(address contractAddress) external onlyRole(PAUSER_ROLE) {

100:     function unpauseContract(address contractAddress) external onlyRole(UNPAUSER_ROLE) {

111:     function emergencyPauseAll() external onlyRole(PAUSE_ALL_ROLE) {

129:     function authorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

141:     function deauthorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/PauserRegistry.sol)

```solidity
File: ./src/StakingAccountant.sol

82:     function authorizeStakingManager(address manager, address kHYPEToken) external onlyRole(MANAGER_ROLE) {

99:     function deauthorizeStakingManager(address manager) external override onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingAccountant.sol)

```solidity
File: ./src/StakingManager.sol

561:     ) external nonReentrant whenNotPaused onlyRole(OPERATOR_ROLE) {

627:     function processL1Operations(uint256 batchSize) public onlyRole(OPERATOR_ROLE) whenNotPaused {

773:     function setTargetBuffer(uint256 newTargetBuffer) external onlyRole(MANAGER_ROLE) {

778:     function setStakingLimit(uint256 newStakingLimit) external onlyRole(MANAGER_ROLE) {

791:     function setMinStakeAmount(uint256 newMinStakeAmount) external onlyRole(MANAGER_ROLE) {

799:     function setMaxStakeAmount(uint256 newMaxStakeAmount) external onlyRole(MANAGER_ROLE) {

814:     function setWithdrawalDelay(uint256 newDelay) external onlyRole(MANAGER_ROLE) {

822:     function enableWhitelist() external onlyRole(MANAGER_ROLE) {

830:     function disableWhitelist() external onlyRole(MANAGER_ROLE) {

839:     function addToWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

852:     function removeFromWhitelist(address[] calldata accounts) external onlyRole(MANAGER_ROLE) {

885:     function pauseStaking() external onlyRole(MANAGER_ROLE) {

893:     function unpauseStaking() external onlyRole(MANAGER_ROLE) {

901:     function pauseWithdrawal() external onlyRole(MANAGER_ROLE) {

909:     function unpauseWithdrawal() external onlyRole(MANAGER_ROLE) {

919:     function cancelWithdrawal(address user, uint256 withdrawalId) external onlyRole(MANAGER_ROLE) whenNotPaused {

946:     function redelegateWithdrawnHYPE() external onlyRole(MANAGER_ROLE) whenNotPaused {

963:     function resetL1OperationsQueue() external onlyRole(MANAGER_ROLE) {

979:     function setUnstakeFeeRate(uint256 newRate) external onlyRole(MANAGER_ROLE) {

986:     function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {

994:     function withdrawFromSpot(uint64 amount) external onlyRole(OPERATOR_ROLE) {

1007:     function withdrawTokenFromSpot(uint64 tokenId, uint64 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

1028:     function rescueToken(address token, uint256 amount) external onlyRole(TREASURY_ROLE) whenNotPaused {

1049:     ) external nonReentrant whenNotPaused onlyRole(SENTINEL_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/StakingManager.sol)

```solidity
File: ./src/ValidatorManager.sol

131:     function activateValidator(address validator) external whenNotPaused onlyRole(MANAGER_ROLE) {

177:     ) external whenNotPaused nonReentrant onlyRole(MANAGER_ROLE) validatorExists(validator) {

203:     ) external whenNotPaused nonReentrant onlyRole(MANAGER_ROLE) {

253:     ) external whenNotPaused nonReentrant onlyRole(MANAGER_ROLE) {

311:     ) external whenNotPaused onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {

412:     ) external onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {

430:     ) external onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {

450:     ) external whenNotPaused onlyRole(MANAGER_ROLE) validatorActive(validator) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/ValidatorManager.sol)

```solidity
File: ./src/oracles/DefaultOracle.sol

11: contract DefaultOracle is AccessControl {

90:     ) external onlyRole(OPERATOR_ROLE) {

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/oracles/DefaultOracle.sol)

### <a name="M-3"></a>[M-3] Direct `supportsInterface()` calls may cause caller to revert
Calling `supportsInterface()` on a contract that doesn't implement the ERC-165 standard will result in the call reverting. Even if the caller does support the function, the contract may be malicious and consume all of the transaction's available gas. Call it via a low-level [staticcall()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L119), with a fixed amount of gas, and check the return code, or use OpenZeppelin's [`ERC165Checker.supportsInterface()`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L36-L39).

*Instances (2)*:
```solidity
File: ./src/KHYPE.sol

110:         return super.supportsInterface(interfaceId);

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/KHYPE.sol)

```solidity
File: ./src/OracleManager.sol

100:         require(IOracleAdapter(adapter).supportsInterface(type(IOracleAdapter).interfaceId), "Invalid adapter");

```
[Link to code](https://github.com/code-423n4/2025-04-kinetiq/blob/main/./src/OracleManager.sol)

