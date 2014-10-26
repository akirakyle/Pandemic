<?php

class Node {
	public $classification = "";
	public $type = "";
	public $value = 0;
	public $x = 0;
	public $y = 0;
	public $shield = FALSE;
	public $uid = 0;
}

class PandemicServer {
	private $cnx;
	private $NODES;
	private $RADIUS = 30;
	
	function __construct() {
		$this->cnx = mysqli_connect("localhost", "root", "", "pandemic");
	}
	
	function __destruct() {
		mysqli_close($this->cnx);
	}
	
	function populateNodes() {
		$this->NODES = array();
		$query = "SELECT classification, type, value, x, y, shield, uid FROM nodes";
		$allRows = mysqli_query($this->cnx, $query);
		while($row = mysqli_fetch_array($allRows)) {
			$currentNode = new Node;
			$currentNode->classification = $row["classification"];
			$currentNode->type = $row["type"];
			$currentNode->value = $row["value"];
			$currentNode->x = $row["x"];
			$currentNode->y = $row["y"];
			$currentNode->shield = $row["shield"];
			$currentNode->uid = $row["uid"];
			# Add to list of nodes
			array_push($this->NODES, $currentNode);
		}
	}
	
	function main() {
		if ((isset($_POST["init"])) and ($_POST["init"] == 1)) {
			# First time contacting the server, add this player to database
			# POST request should have sent all Node data
			$classification = $_POST["classification"];
			$type = $_POST["type"];
			$value = $_POST["value"];
			$x = $_POST["x"];
			$y = $_POST["y"];
			$shield = $_POST["shield"];
			$query = "SELECT MAX(uid) AS max FROM nodes;";
			$row = mysqli_fetch_array(mysqli_query($this->cnx, $query));
			$uid = $row["max"] + 1;
			$query = "INSERT INTO nodes 
			VALUES ('$classification', '$type', '$value', '$x', '$y', '$shield', '$uid')";
			mysqli_query($this->cnx, $query);
			# Add to the contact table
			$colName = "c$uid";
			$query = "ALTER TABLE contact ADD $colName TINYINT(1) NOT NULL DEFAULT 0;";
			file_put_contents("log.txt", "$colName");
			mysqli_query($this->cnx, $query);
			$query = "INSERT INTO contact () VALUES();";
			mysqli_query($this->cnx, $query);
			$query = "UPDATE contact SET uid = '$uid' WHERE uid = 0;";
			mysqli_query($this->cnx, $query);
			# Update NODES
			$this->populateNodes();
			# Send response
			$finalResponse = array();
			$initArray = array("calltype" => "init");
			array_push($finalResponse, $initArray);
			$uidArray = array("uid" => $uid);
			array_push($finalResponse, $uidArray);
			echo(json_encode($finalResponse));
		}
		else if ((isset($_POST["alldata"])) and ($_POST["alldata"] == 1)) {
			# Send all the data so the app can populate the map or refresh all its records
			$this->populateNodes();
			$finalResponse = array();
			$alldataArray = array("calltype" => "alldata");
			array_push($finalResponse, $alldataArray);
			foreach ($this->NODES as $node) {
				array_push($finalResponse, $node);
			}
			echo(json_encode($finalResponse));
		}
		else if ((isset($_POST["setscore"])) and ($_POST["setscore"] == 1)) {
			# Receiving the score of the player and adding it to the database
			# Request should have player's name and score (in seconds)
			$name = $_POST["name"];
			$score = $_POST["score"];
			$query = "INSERT INTO scores VALUES('$name', '$score');";
			mysqli_query($this->cnx, $query);
			$finalResponse = array();
			$setscoreArray = array("calltype" => "setscore");
			array_push($finalResponse, $setscoreArray);
			echo(json_encode($finalResponse));
		}
		else if ((isset($_POST["getscore"])) and ($_POST["getscore"] == 1)) {
			# Return the database
			$finalResponse = array();
			$getscoreArray = array("calltype" => "getscore");
			array_push($finalResponse, $getscoreArray);
			$query = "SELECT name, score FROM scores;";
			$allRows = mysqli_query($this->cnx, $query);
			while ($row = mysqli_fetch_array($allRows)) {
				$name = $row["name"];
				$score = $row["score"];
				$scoreArray = array("name" => $name, "score" => $score);
				array_push($finalResponse, $scoreArray);
			}
			echo(json_encode($finalResponse));
		}
		else if ((isset($_POST["setvalue"])) and ($_POST["setvalue"] == 1)) {
			# Sets the immunity value - receives value and uid
			$value = $_POST["value"];
			$uid = $_POST["uid"];
			$query = "UPDATE nodes SET value = '$value' WHERE uid = '$uid';";
			mysqli_query($this->cnx, $query);
			$finalResponse = array();
			$setvalueArray = array("calltype" => "setvalue");
			array_push($finalResponse, $setvalueArray);
			echo(json_encode($finalResponse));
		}
		else if ((isset($_POST["ping"])) and ($_POST["ping"] == 1)) {
			# General case - update data and do calculations
			# POST request should have x, y, uid
			$x = $_POST["x"];
			$y = $_POST["y"];
			$uid = $_POST["uid"];
			$query = "SELECT type, value FROM nodes WHERE uid = '$uid';";
			$row = mysqli_fetch_array(mysqli_query($this->cnx, $query));
			$type = $row["type"];
			$value = $row["value"];
			# Shield (for later)
			# Update the database with your data
			$query = "UPDATE nodes SET x = '$x', y = '$y' WHERE uid = '$uid';";
			mysqli_query($this->cnx, $query);
			$this->populateNodes();
			# Now check for nodes within radius
			$interactNodes = array();
			$nodeCount = 0;
			$friendlyNodeCount = 0;
			foreach ($this->NODES as $node) {
				if ((abs($node->x - $x) < $this->RADIUS) and (abs($node->y - $y) < $this->RADIUS) and ($node->x != $x) and ($node->y != $y)) {
					array_push($interactNodes, $node);
					if (($node->type == "virus") and ($type == "cure")) {
						$nodeCount = $nodeCount + 1;
					}
					if (($node->type == "cure") and ($type == "cure")) {
						$friendlyNodeCount = $friendlyNodeCount + 1;
					}
				}
			}
			# Compare all the nodes that the player has interacted with
			foreach ($interactNodes as $node) {
				# Player is not infected
				if ($type == "cure") {
					if ($node->type == "virus") {
						# Calculate probability of infection
						$probability = 100; # Add actual calculation here
						$random = rand(0, 99);
						if ($random < $probability) {
							if ($value == 1) {
								# Infected
								$query = "UPDATE nodes SET type = 'virus' WHERE uid = '$uid';";
								mysqli_query($this->cnx, $query);
							}
							# Decrement immunity by 1
							$query = "UPDATE nodes SET value = value - 1 WHERE uid = '$uid';";
							mysqli_query($this->cnx, $query);
							$value = $value - 1;
						}
					}
					if (($node->type == "cure") and ($uid != $node->uid)) {
						# Exchange cure information
						# Check if we have hit the node already
						$colName = "c$node->uid";
						$query = "SELECT $colName FROM contact WHERE uid = '$uid';";
						$hitNode = mysqli_fetch_array(mysqli_query($this->cnx, $query));
						if ($hitNode[$colName] == 0) {
							# Have not already exchanged cure data with this node
							$query1 = "UPDATE nodes SET value = value + '$node->value' WHERE uid = '$uid';";
							$query2 = "UPDATE nodes SET value = value + '$value' WHERE uid = '$node->uid';";
							#mysqli_query($this->cnx, $query1); # Update current node's value
							#mysqli_query($this->cnx, $query2); # Update other node's value
							# Mark the nodes as having hit each other
							$colName = "c$node->uid";
							$query3 = "UPDATE contact SET $colName = 1 WHERE uid = '$uid';";
							$colName = "c$uid";
							$query4 = "UPDATE contact SET $colName = 1 WHERE uid = '$node->uid';";
							mysqli_query($this->cnx, $query3); # My node hit other node
							mysqli_query($this->cnx, $query4); # Other node hit my node
							#$friendlyNodeCount = $friendlyNodeCount + 1;
						}
					}
				}
			}
			# Return data
			$query = "SELECT type, value FROM nodes WHERE uid = '$uid';";
			$row = mysqli_fetch_array(mysqli_query($this->cnx, $query));
			$type = $row["type"];
			$value = $row["value"];
			# Generate final response (calltype, type, value, nodeCount)
			$finalResponse = array();
			$pingArray = array("calltype" => "ping");
			array_push($finalResponse, $pingArray);
			$typeArray = array("type" => $type);
			array_push($finalResponse, $typeArray);
			$valueArray = array("value" => $value);
			array_push($finalResponse, $valueArray);
			$nodeCountArray = array("nodeCount" => $nodeCount);
			array_push($finalResponse, $nodeCountArray);
			$friendlyNodeCountArray = array("friendlyNodeCount" => $friendlyNodeCount);
			array_push($finalResponse, $friendlyNodeCountArray);
			echo(json_encode($finalResponse));
		}
	}
}

$server = new PandemicServer;
$server->main()

?>