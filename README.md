# A [Battlesnake](http://play.battlesnake.com) using an ANN written in Mule and DataWeave

This is an implementation of the [Battlesnake API](https://docs.battlesnake.com/snake-api). It's a total abuse of Dataweave to implement a neural network. But hey it's fun.

# Particulars

This is an implementation of a DQN - the application of a neural network for the Policy of a Q Learning algorithm. We keep the neural network state in an object store, so that the weights are available each turn. We also keep the episode history in an object store so that it's available to learn from.

When the game ends, we will use the result of the game as the Reward function, and update the weights according to the result of the game. The agent will not learn during the course of a single game, it will only learn once we find out if we won or lost.

The Observation is 5 cells forward of the snake's head, 3 cells to the left, and 3 cells to the right. For each cell, we use one hot encoding to indicate the presence of food or a hazard. We also provide the current health and length of our snake.

 We chose to use 2 hidden layers, with more nodes in layer 1 than in layer 2. We used the sigmoid function on each layer to normalize the data.

