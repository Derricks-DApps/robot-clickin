// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Network {
    struct User {
        string tester_name;
        uint256 qa_score;
        address wallet;
    }

    // Mapping of addresses to user profiles
    mapping(address => User) private users;

    // List of registered users (for simplicity, used for pairing)
    address[] private userAddresses;

    // Events
    event UserRegistered(address indexed userAddress, string tester_name, uint256 qa_score);
    event MatchFound(address indexed user1, address indexed user2, uint256 scoreDifference);

    // Modifier to check if the user is already registered
    modifier notRegistered() {
        require(users[msg.sender].wallet == address(0), "User already registered");
        _;
    }

    // Register a new user with a credit score
    function registerUser(string calldata name, uint256 qa_score) external notRegistered {
        require(qa_score > 0, "Credit score must be positive");

        users[msg.sender] = User(tester_name, qa_score, msg.sender);
        userAddresses.push(msg.sender);

        emit UserRegistered(msg.sender, name, qa_score);
    }

    // Match user with another user based on credit score proximity
    function findMatch() external view returns (address matchedUser, uint256 scoreDifference) {
        require(users[msg.sender].wallet != address(0), "User not registered");

        User memory currentUser = users[msg.sender];
        uint256 closestScoreDiff = type(uint256).max; // Start with max value
        address closestUser;

        for (uint256 i = 0; i < userAddresses.length; i++) {
            if (userAddresses[i] != msg.sender) {
                User memory otherUser = users[userAddresses[i]];
                uint256 scoreDiff = abs(currentUser.creditScore, otherUser.creditScore);

                if (scoreDiff < closestScoreDiff) {
                    closestScoreDiff = scoreDiff;
                    closestUser = otherUser.wallet;
                }
            }
        }

        return (closestUser, closestScoreDiff);
    }

    // Utility to calculate absolute difference
    function abs(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? (a - b) : (b - a);
    }

    // Retrieve user details (for demonstration)
    function getUserDetails(address userAddress) external view returns (string memory tester_name, uint256 qa_score) {
        require(users[userAddress].wallet != address(0), "User not registered");
        User memory user = users[userAddress];
        return (user.tester_name, user.qa_score);
    }

    // Get total registered users count
    function getTotalUsers() external view returns (uint256) {
        return userAddresses.length;
    }
}
