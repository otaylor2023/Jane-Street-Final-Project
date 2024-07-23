---
title: Wiki Game
---

In this project, you will use knowledge about HTML, graphs, and graph search to implement a
[Wiki Game](https://en.wikipedia.org/wiki/Wikipedia:Wiki_Game) player.

# Getting started

## Prep work

First, fork this repository by visiting [this
page](https://github.com/jane-street-immersion-program/wiki-game/fork) and clicking on the
green "Create fork" button at the bottom.

Then clone the fork locally (on your AWS machine) to get started. You can clone a repo on
the command line like this (where `$USER` is your GitHub username):

```
$ git clone git@github.com:$USER/wiki-game.git
Cloning into 'wiki-game'...
remote: Enumerating objects: 61, done.
remote: Counting objects: 100% (61/61), done.
remote: Compressing objects: 100% (57/57), done.
remote: Total 61 (delta 2), reused 61 (delta 2), pack-reused 0
Receiving objects: 100% (61/61), 235.81 KiB | 6.74 MiB/s, done.
Resolving deltas: 100% (2/2), done.
```

Now you should be able to enter the project directory, build the starter code, and run the
executable binary like this:

```
$ cd wiki-game/
$ dune build
$ dune runtest
$ dune exec ./bin/wiki_game.exe -- help
```

## Directory layout

The files for these exercises are contained in the following directories:
| directory | file(s)                                                                        | description                                                                                                                                                              |
|-----------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `src`     | `file_fetcher.ml(i)` and `file_fetcher_demo.ml(i)`                             | a small OCaml library for reading files (either remotely or locally), and a demo of its usage                                                                            |
|         | `wikipedia_namespace.ml(i)`                                                    | a small OCaml library for handling Wikipedia namespaces, which you will encounter later in this exercise                                                                 |
|         | `lambda_soup_utilities.ml(i)`                                                  | a demo for using the [Lambda Soup](https://github.com/aantron/lambdasoup) OCaml library to parse HTML; you'll also add some functionality in this library in an exercise |
|         | `imdb.ml`, `interstate.ml`, `maze.ml`, `social_network.ml`, and `wiki_game.ml` | these are the other files you will modify to complete the exercises                                                                                                      |
|         | `wiki_game_lib.ml(i)`                                                          | a module that wraps up all of the commands implemented here                                                                                                              |
| `bin`     | `wiki_game.ml(i)`                                                              | a wrapper for calling the commands from `Wiki_game_lib`                                                                                                                  |
| `resources` | `friends.txt`                                                                  | a file describing pairwise friendships, for use with the exercises from the [`Social_network`](./src/social_network.mli) module                                              |
|         | `interstate.txt`                                                               | a file that lists US interstate highways and major cities that they run through, for use with exercises from the [`Interstate`](./src/interstate.mli) module             |
|         | `maze_{small,medium,large}.txt`                                                | files that contain sample mazes, for use with exercises from the [`Maze`](./src/maze.mli) module                                                                         |
|         | `wiki`                                                                         | a directory that contains a small dataset of Wikipedia-like articles, for use with exercises from the [`Wiki_game`](./src/wiki_game.mli) module                          |
| `web-dev`    | `index.html`, `index.js`, `style.css`                                      | starter code for your personal blog |
| `test`      | `wiki_game_test.ml(i)`                                                          | starter code for unit tests you may wish to write |
| `images`    | | contains some images that are referenced in this README |

# HTML

The exercises for the [HTML](#html) and [Web scraping](#web-scraping) sections are
intended to be completed after the HTML talk, but you are welcome to browse ahead. Feel
free to grab a TA if you have any questions.

## Exercise 1: Creating a webpage

To familiarize ourselves with HTML documents, let's create a webpage of our own.

In `web-dev/index.html`, you'll find some boilerplate to get you started.

Between the `<body></body>` tags, add anything you want to appear on your webpage. For
some guidelines, try to include the following elements in your page:

- A large header, using the `h1` element
- Some subsection, using the `h2` elements or other such subheading elements
- An unordered list `ul`
- An ordered ist `ol`
- A `table` with a `th` header row
- At least 1 `img` of your choosing
- A link `a` to another page that you create from scratch

You can check out [w3schools](https://www.w3schools.com/tags/default.asp) for a reference
on HTML elements. There are also plenty of other resources on the internet, and feel free
to ask a TA if you need any help.

You may add any other content to your webpages that you'd like. Don't hesitate to get
creative!

Note that the directory and HTML template includes a stylesheet named `style.css` and
JavaScript file named `index.js`. If you would like to add some styling to your document,
modify those files to your liking.

Once you have written your html, css, and javascript, `cd` into the web-dev directory and
start a HTTP server with:

```
$ python3 -m http.server 8080
```

Find your hostname:

```
$ curl http://169.254.169.254/latest/meta-data/public-hostname
```

Navigate your browser to:

```
<YOUR-HOST-NAME>:8080
```

And you will see your webpage!

## Exercise 2: Inspecting your webpage

Google Chrome provides builtin tools for inspecting the source code of any website you
visit. To open these tools, right-click any element on the page and click `Inspect`. This
will open a panel in which you can hover over bits of HTML which will cause Chrome to
highlight the corresponding sections of the webpage.

Now that you've written some HTML, try using the Chrome inspector tool to look at your
webpage.

# The `Command` module

In the rest of this project, we will be encountering a number of commandline
tools. In OCaml, we use the `Command` library to write apps that take commandline
arguments. 

Let's take a brief detour here to learn about the `Command` library. Take a look at the
command-demo directory on your box for a sample usage and explanations. 

# Web scraping

In this section, we'll put our knowledge of HTML to use by building some tools to read and
parse webpages.

## Fetching webpages

We have already implemented a simple library for fetching resources via HTTP in the
[File_fetcher](./src/file_fetcher.mli) module. This module also provides a built-in way to
switch to reading files locally, so that it's easy to test with custom files on your
computer. You don't need to understand the details of how this logic is implemented, but
you should be able to use it. See [File_fetcher_demo](./src/file_fetcher_demo.mli) for an
example. You can download a webpage by running the following from the repository's root
directory:

```
$ dune exec ./bin/wiki_game.exe -- file-fetcher-demo -resource https://en.wikipedia.org/wiki/Cat
```

You can also try out the functionality to read files locally via:
```
$ dune exec ./bin/wiki_game.exe -- file-fetcher-demo -local-with-root resources -resource
/wiki/Cat
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Cat - Wikipedia</title>
  </head>
  <body>
    <p>The cat is a <a href="/wiki/Domestication_of_the_cat"
    title="Domestication of the
    cat">domestic</a> <a href="/wiki/Species">species</a> of
    small <a href="/wiki/Carnivore">carnivorous</a> <a href="/wiki/Mammal">mammal</a>.</p>

    <p><a href="/wiki/Talk:Cat">Talk</a></p>
  </body>
</html>
```

We will use this tiny `File_fetcher` library to grab webpages in our web-scraping
exercises.

Before continuing, please take a look at the `File_fetcher` library and try out the
commands above.

## Parsing HTML

The library we will use for parsing HTML in code is called [Lambda
Soup](https://github.com/aantron/lambdasoup). Take a quick look at
[lambda_soup_utilities.ml](./src/lambda_soup_utilities.ml) to see some examples of the
library in action. You can run the implemented utilities like so:
```
$ dune exec ./bin/wiki_game.exe -- lambda-soup-utilities print-title -resource https://en.wikipedia.org/wiki/Cat
Cat - Wikipedia
```

```
$ dune exec ./bin/wiki_game.exe -- lambda print-list-items -local-with-root resources -resource /wiki/Carnivore
All feliforms, such as domestic cats, big cats, hyenas, mongooses, civets
Almost all caniforms, such as the dogs, wolves, foxes, ferrets, seals and walruses
All cetaceans, such as dolphins, whales and porpoises
All bats except fruitbats
The carnivorous marsupials, such as the Tasmania devil
All birds of prey, such as hawks, eagles, falcons and owls
All vultures, both old world and new
Most waterfowl, such as gulls, penguins, pelicans, storks, and herons
```

## Exercises

Now that we have the tools to both fetch HTML pages from the internet and parse them in
OCaml, let's try combining them. The following exercises will require you to use the
`File_fetcher` library to grab a page from the internet and extract some information from
them.

### Exercise 1: HTML parsing utilities

To get our feet wet with these libraries, let's write a few utility functions for
extracting certain elements from HTML webpages. In
[lambda_soup_utilities.ml](./src/lambda_soup_utilities.ml):

1. Implement `print-first-item-of-all-unordered-lists` by completing the
   `get_first_item_of_all_unordered_lists` function.
2. Implement `print-first-item-of-second-unordered-list` by completing the
   `get_first_item_of_second_unordered_list` function.
3. Implement `print-bolded-text` by completing the `get_bolded_text` function.

For each of these exercises, try writing an expect test to verify its behavior in
[test/wiki_game_test.ml](./test/wiki_game_test.ml). Note that you will also need to expose
these functions in [src/lambda_soup_utilities.mli](./src/lambda_soup_utilities.mli) in
order to access them for your tests. An example expect test for the `get_title`
function is already implemented.

You can also test your implementation locally on [resources/wiki/Carnivore](./resources/wiki/Carnivore):
```
$ dune exec ./bin/wiki_game.exe -- lambda-soup-utilities print-first-item-of-all-unordered-lists -local-with-root resources -resource /wiki/Carnivore
All feliforms, such as domestic cats, big cats, hyenas, mongooses, civets
All birds of prey, such as hawks, eagles, falcons and owls
```
```
$ dune exec ./bin/wiki_game.exe -- lambda-soup-utilities print-first-item-of-second-unordered-list -local-with-root resources -resource /wiki/Carnivore
All birds of prey, such as hawks, eagles, falcons and owls
```
```
$ dune exec ./bin/wiki_game.exe -- lambda-soup-utilities print-bolded-text -local-with-root resources -resource /wiki/Carnivore
carnivore
Predators
Scavengers
insectivores
piscivores
```

Finally, you should try testing your implementations on a page of your choosing on the
internet!

### Exercise 2: scraping Wikipedia

Now, let's put our skills to use by implementing a function that extracts all of the links
in a Wikipedia article that link to another Wikipedia article. Implement `get_linked_articles` function
in [wiki_game.ml](./src/wiki_game.ml).

Note that there is a bit of nuance in this exercise:
- Not all links on a Wikipedia article are links within Wikipedia; there are external links
  as well.
- Not all of the Wikipedia links on a Wikipedia article are links to other articles;
  Wikipedia has a set of reserved [namespace
  keywords](https://en.wikipedia.org/wiki/Wikipedia:Namespace) that are used for metadata
  and content other than articles. We have already implemented a small library for
  handling Wikipedia namespaces. Take a look over
  [wikipedia_namespace.mli](./src/wikipedia_namespace.mli) to learn more.

As with before, let's try writing an expect test for your `get_linked_articles` function
in [test/wiki_game_test.ml](./test/wiki_game_test.ml). (Remember that you may need to
add your function to [wiki_game.mli](./src/wiki_game.mli) to use it in your test.)

You can also test your implementation locally using any of the pages in the [Wikipedia test
dataset](./resources/wiki). For example:
```
$ dune exec ./bin/wiki_game.exe -- wiki-game print-links -local-with-root resources -resource /wiki/Cat
/wiki/Carnivore
/wiki/Domestication_of_the_cat
/wiki/Mammal
/wiki/Species
```

Finally, you should test your implementation on some real Wikipedia pages, such as:
```
$ dune exec ./bin/wiki_game.exe -- wiki-game print-links -resource https://en.wikipedia.org/wiki/Endara
/wiki/Endara
/wiki/Given_name
/wiki/Guido_J._Martinelli_Endara
/wiki/Guillermo_Endara
/wiki/Iv%C3%A1n_Endara
/wiki/Main_Page
/wiki/Surname
```

### Exercise 3: scraping IMDB

To really stretch our skills, let's implement a command that can take an IMDB actor page,
such as https://www.imdb.com/name/nm0000706/?ref_=fn_al_nm_1, and print out a list of the
main credits of the actor.

For this exercise, you'll likely need to dig into filtering out nodes based on specific
node attributes or classes. It may be useful to inspect the HTML page in chrome to figure
out how to identify the relevant nodes for this task.

Implement the `print-credits` command in [imdb.ml](./src/imdb.ml) by implementing the
`get_credits` function. 

Once again, test your work by adding an expect test for `get_credits` in
[test/wiki_game_test.ml](./test/wiki_game_test.ml).

You should also test your implementation by running it on an IMDB page of your choosing, like so:

```
$ dune exec ./bin/wiki_game.exe -- imdb print-credits -resource https://www.imdb.com/name/nm0000706/?ref_=fn_al_nm_1
Crazy Rich Asians
Crouching Tiger, Hidden Dragon
Everything Everywhere All at Once
Tomorrow Never Dies
```

Note that depending on how you choose to implement your parsing, your output may not be
exactly the same as the above. If you have any questions, feel free to consult a TA!

# Graphs

This section and exercises are intended to be completed after the Introduction to Graphs
talk, but you are welcome to browse ahead. Feel free to grab a TA if you have any
questions.

## Visualizing graphs in OCaml

When working with graphs, it's often useful to be able to see what the graph looks like,
rendered as nodes and edges in a human-consumable way. The
[OCamlgraph](https://github.com/backtracking/ocamlgraph) library helps us accomplish this
by giving us utilities for constructing a graph and outputting it as a
[DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) file.

Take a look at [social_network.ml](./src/social_network.ml) for an example of
how we can use OCamlgraph to generate visualizations of graphs. From the root of the repo,
you can run this example like so:
```
$ dune exec ./bin/wiki_game.exe -- social-network visualize -input resources/friends.txt -output /tmp/friends.dot
```

Then, you can render the outputted DOT file as a PDF:
```
cat /tmp/friends.dot | dot -Tpdf -o ~/friends.pdf
```

Open up `~/friends.pdf` in VSCode to see the graph. You should see something like:

<center>
<img src="./images/friends.png" width="500">
</center>

You can also take a look at the input [friends.txt](./resources/friends.txt) file to see
if the outputted graph matches your expectations.

## Exercise: interstate map

Let's practice building a representation of a graph in OCaml and visualizing it using
ocamlgraph's DOT API.

While we could just use the ocamlgraph graph data structure directly for representing the
graph in code, we can use this opportunity to practice design a data structure that
models real-life graphs that lets us easily answer questions about the graph.

The United States [Interstate Highway
System](https://en.wikipedia.org/wiki/Interstate_Highway_System), also known as the Dwight
D. Eisenhower National System of Interstate and Defense Highways, is a network of
controlled-access highways that forms a part of the National Highway System in the United
States. It is one of the most extensive networks of highways in the world. It spans about
48,000 miles, connecting all 48 contiguous U.S. states, as well as the District of
Columbia and some territories.

In this exercise, we will visualize some of the Interstate Highway System as a graph,
where the nodes are cities, and two cities have an edge between them if they are connected
by the same interstate highway (they do not need to be consecutive cities on the
highway). The input file [interstate.txt](./resources/interstate.txt) has a list of
interstate highways along with a list of some of the major cities that the interstate runs
through. 

We'll be writing our code as the `load` and `visualize` commands in
[interstate.ml](./src/interstate.ml). First, we'll need to read in the input file. If you
haven't yet, see how we read and parsed comma-separated files in
[social_network.ml](./src/social_network.ml). Once we can parse the input file,
we can then construct our graph.

You should take a bit of time to explore the ocamlgraph API. See if you can render your
graph such that the edges are labeled with the interstates that connect each of the
cities.

You can test your implementation like so:
```
$ dune exec ./bin/wiki_game.exe -- interstate visualize -input resources/interstate.txt -output /tmp/interstate.dot
$ cat /tmp/interstate.dot | dot -Tpdf -o ~/interstate.pdf
```

Note: One rough edge you might run into with the ocamlgraph API is that the DOT format does
not play well with vertex names that have periods in them, which some of the cities
do. You can escape these names with double quotes, or replace all instances of "."  in
city names.

# Graph search

This section and exercises are intended to be completed after the Introduction to Graph
Search talk, but you are welcome to browse ahead. Feel free to grab a TA if you have any
questions.

## Exercises

### Exercise 1: friend groups

In this exercise, we will identify friend groups using breadth-first search. For our
purpose, a "friend group" is a group of people where any two people are connected via a
sequence of mutual friends, and every friend of a person who is a part of the group is
also a part of a group.

For a concrete example, take a look at the `friends.pdf` graph from
[above](#visualizing-graphs-in-ocaml). Notice how in this graph, "romeo" and "juliet" (red
square) are connected to each other, but are completely separated from the other friends
(blue square):

<center>
<img src="./images/friend_groups.png" width="500">
</center>

If we query our graph for the whole friend group containing "romeo", we should output
"romeo" and "juliet". If we query our graph for the whole friend group containing "alpha",
we should output "alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel",
"india", "kilo", and "lima".

Let's implement the `find-friend-group` command in
[social_network.ml](./src/social_network.ml).

You can test your implementation using the [sample input file](./resources/friends.txt):
```
$ dune exec ./bin/wiki_game.exe -- social-network find-friend-group -input resources/friends.txt -person romeo
romeo
juliet
```

```
$ dune exec ./bin/wiki_game.exe -- social-network find-friend-group -input resources/friends.txt -person alpha
bravo
echo
delta
lima
india
foxtrot
golf
kilo
hotel
charlie
alpha
```

You should also write an expect test for this function in
[test/wiki_game_test.ml](./test/wiki_game_test.ml).

### Exercise 2: wiki mapper

Let's go back to our Wikipedia game player. Earlier, we implemented logic
to parse out links between Wikipedia articles. Now, let's build a graph showing how
articles are connected to each other.

Similar to the [interstate mapping exercise](#exercise-interstate-map), we'll want to generate
a dot file showing how the different wikipedia pages are linked. Unlike the interstate
mapping exercise, we won't know up front what the edges in our graph are, so we'll need to
explore our graph to enumerate the edges.

One thing worth thinking about is how to represent articles in your graph. Naively, we can
represent them using their URLs, but it might be nicer to store an article as a record
containing both its URL and its title so that we can reduce the verbosity of our output.

Let's implement the `visualize` command in [wiki_game.ml](./src/wiki_game.ml).

You can test your implementation using the [local Wikipedia dataset](./resources/wiki) by
running the following from the root of your clone:

```
$ dune exec ./bin/wiki_game.exe -- wiki-game visualize -origin wiki/Cat -local resources -output /tmp/wiki.dot
Done! Wrote dot file to /tmp/wiki.dot
$ cat /tmp/wiki.dot | dot -Tpdf -o ~/wiki.pdf
```

The generated PDF file containing the visualization of the graph should look something
like this:

<center>
<img src="./images/wiki.png" width="700">
</center>


### Exercise 3: maze solver

In this exercise, let's build a maze solver using depth-first search.

To begin, let's look at how our mazes are represented in the input files. Open up
[maze_small.txt](./resources/maze_small.txt). In this file, we have a maze represented as
a grid of characters where `#` represents a wall, `.` represents an open space, `S`
represents the start of the maze, and `E` represents the end of the maze.

How can we represent this maze as a graph? To make a decision here, think about what
questions you'll want to answer about the maze in order to write a solver. In addition to
implementing the solver, you should also think about how you'll want to display a
solution.

Let's implement the `solve` command in [maze.ml](./src/maze.ml).

Try to implement the command in a way that allows you to write an expect test. You should
also make sure to test your command in the commandline using the
[maze_small.txt](./resources/maze_small.txt),
[maze_medium.txt](./resources/maze_medium.txt), and
[maze_large.txt](./resources/maze_large.txt) files. 

### Exercise 4: wiki racer

Once again back to the Wikipedia game player. Let's now use use our experience creating
and searching graphs to implement a wiki game player. Given an origin and a destination
page, the wiki game player should find a path between the two pages.

Implement the `find-path` command in [wiki_game.ml](./src/wiki_game.ml).

You can test your implementation using the [local Wikipedia dataset](./resources/wiki) by
running the following from the root of your clone:

```
$ dune exec ./bin/wiki_game.exe -- wiki-game find-path -origin /wiki/Cat -destination /wiki/Dog -local-with-root resources/
Cat - Wikipedia
Carnivore - Wikipedia
Caniformia - Wikipedia
Dog - Wikipedia
```

Note that depending on your implementation, your output may look a bit different.

You can also test your implementation on actual Wikipedia. For example:
```
$ dune exec ./bin/wiki_game.exe -- wiki-game find-path -origin https://en.wikipedia.org/wiki/Endara -destination https://en.wikipedia.org/wiki/Guido_J._Martinelli_Endara
Endara - Wikipedia
Guido J. Martinelli Endara - Wikipedia
```

```
$ dune exec ./bin/wiki_game.exe -- wiki-game find-path -origin https://en.wikipedia.org/wiki/Endara -destination https://en.wikipedia.org/wiki/Consejo_Nacional_de_Relaciones_Exteriores
Endara - Wikipedia
Guido J. Martinelli Endara - Wikipedia
Consejo Nacional de Relaciones Exteriores - Wikipedia
```

```
$ dune exec ./bin/wiki_game.exe -- wiki-game find-path -origin https://en.wikipedia.org/wiki/Acoustic_Kitty -destination https://en.wikipedia.org/wiki/Age_of_Discovery
Acoustic Kitty - Wikipedia
Cat - Wikipedia
Age of Discovery - Wikipedia

dune exec ./bin/wiki_game.exe -- wiki-game find-path -origin https://en.wikipedia.org/wiki/Tesla_Cybertruck -destination https://en.wikipedia.org/wiki/Latin
```

You may notice that your implementation can be very slow to find paths on certain inputs
(including the second and third examples above). That's normal! Do you see why? Grab a TA or another
fellow to discuss!

In the next section, we'll learn about some ways that we can make graph search faster.

# Advanced graph search

This section and exercises are intended to be completed after the Advanced Graph Search
talk, but you are welcome to browse ahead. Feel free to grab a TA if you have any
questions.

## Exercises

### Exercise 1: Dijkstra's Algorithm

In [`dijkstra.ml`](./src/dijkstra.ml) you will find some data structures and function
stubs that will help you implement Dijkstra's algorithm for finding the shortest path
between two nodes in a weighted graph (as discussed in your advanced graph search talk).

There are a handful of exercises that require you to implement some helper functions
before finally implementing Dijkstra's algorithm in the `shortest_path` function. Head to
[`dijkstra.ml`](./src/dijkstra.ml) for instructions. 

For a refresher on the algorithm, you may use the [wikipedia
page](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Algorithm) or other high level
descriptions you may find. Be wary not to overfit your solution to any pseudocode or
reference impementation you may come by as this OCaml implementation is probably quite
different.

### Exercise 2: Optimized wiki racer

Now that we have some more tools in our graph search toolbelt, let's try to improve our
implementation of the Wikipedia game player from above. What are some heuristics that we
can try to employ to make our search algorithm faster?

Feel free to discuss your ideas with each other and the TAs.

# Extensions

If you've enjoyed building this Wikipedia game player and are interested in more web
scraping projects, here are some ideas:

- IMDB crawler (given two actors, find how they are connected through mutual productions)
- flight mapper (build a scraper to gather data about airlines and the airports they fly to,
  and build a tool that uses this data to find flight itineraries between different cities)
- website crawler/archiver (download a webpage and all of the transitive links in a
  structure that can be hosted locally)
--
