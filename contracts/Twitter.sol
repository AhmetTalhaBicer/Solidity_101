// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Twitter {

    struct Tweet {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    // add our code
    mapping(address => Tweet[] ) public tweets;

    function createTweet(string memory _tweet) public {
        // conditional
        // if tweet length <= 280 then we are good, otherwise we revert
        

        Tweet memory newTweet = Tweet({
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);
    }

    // get tweet func
    function getTweet( uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }
    
    // get all tweet func
    function getAllTweets(address _owner) public view returns (Tweet[] memory ){
        return tweets[_owner];
    }

    // remove tweet func
    function deleteTweet(uint _i) public {
        require(_i < tweets[msg.sender].length, "Tweet index out of bounds");
        
        // Shift all tweets after the specified index to the left
        for (uint i = _i; i < tweets[msg.sender].length - 1; i++) {
            tweets[msg.sender][i] = tweets[msg.sender][i + 1];
        }

        // Remove the last tweet (which is now a duplicate)
        tweets[msg.sender].pop();
    }
}