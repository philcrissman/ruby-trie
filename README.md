# ruby-trie

Just a couple trie implementations in Ruby

The first uses nested hashes. At first I thought it was too slow, but then I wrote and benchmarked the version that uses Node and Nodeset objects. 

Look up is pretty quick in both, but slightly quicker in the version that uses Hashes to store the data. Both are faster than regex matching, so, hooray for data structure!
