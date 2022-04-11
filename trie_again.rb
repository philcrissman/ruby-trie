class DictionaryAgain
  attr_reader :store

  def initialize list
    words = list.split("\n")
    @store = TrieAgain.new
    words.each do |word|
      store.put word
    end
  end
  
  def find(word)
    store.find(word)
  end
end

class TrieAgain
  class NullNode
    class << self 
      def nodeset
        @nodeset ||= [].freeze
      end

      def add value
        false
      end

      def value
        self
      end

      def to_s
        "NULL"
      end
    end

    private
    def initialize
    end
  end

  attr_reader :root

  def initialize
    @root = NodeSet.new
  end

  def put word, nodeset=root
    if word.empty?
      # put the null node into the nodeset
      nodeset.add_null_node
      true
    else
      # put first char into nodeset
      node = nodeset.add word[0]
      # put the rest of the word into that nodes' nodeset
      put word[1..-1], node.nodeset
      true
    end
  end

  def find word, nodeset=root
    if nodeset.empty?
      return false
    elsif word.empty?
      nodeset.include? TrieAgain::NullNode
    else
      find word[1..-1], nodeset.get(word[0]).nodeset if nodeset.get(word[0])
    end
  end

  def to_s
    root.to_s
  end

end

class Node
  attr_reader :value, :nodeset

  def initialize value
    @value = value
    @nodeset = NodeSet.new
  end

  def to_s
    "#{value.to_s} -> [#{nodeset.to_s}]"
  end
end

class NodeSet
  def initialize
    @nodeset = []
  end

  def to_s
    @nodeset.join(",")
  end

  def empty?
    @nodeset.empty?
  end

  def get v
    @nodeset.select{|el| el.value == v}.first
  end

  def add value
    n = Node.new(value)
    add_node n
  end

  def add_null_node
    add_node TrieAgain::NullNode
  end

  def include? value
    @nodeset.map(&:value).include? value
  end

  def size
    @nodeset.size
  end

  private 
  def add_node n
    node = n
    if include? n.value
      node = get n.value
    else
      @nodeset << n unless include? n.value
    end
    node
  end
end

require 'minitest/autorun'
require 'pry'

class TrieAgainTest < Minitest::Test
  def test_the_null_node
    nn = TrieAgain::NullNode
    assert nn.nodeset.empty?
    refute nn.add "anything"
  end

  def test_a_node_has_a_value
    n = Node.new("a")
    assert_equal  "a", n.value
  end

  def test_a_node_has_children
    n = Node.new("a")
    n.nodeset.add("b")
    assert n.nodeset.include? "b"
  end

  def test_nodeset_add_null_node
    n = NodeSet.new
    assert !!n.add_null_node
    assert n.include? TrieAgain::NullNode
  end

  def test_nodeset_acts_like_a_set
    n = NodeSet.new
    n.add "a"
    n.add "b"
    n.add "a"

    assert_equal 2, n.size
  end

  def test_add_null_node
    n = NodeSet.new
    n.add "a"
    n.add "b"
    n.add_null_node

    assert_equal 3, n.size
    assert n.include? "a"
    assert n.include? "b"
    assert n.include? TrieAgain::NullNode
  end

  def test_add_null_node_in_nested_nodes
    nroot = NodeSet.new
    first = nroot.add "a"
    
    nnext = first.nodeset
    nnext.add "b"

    assert nroot.include? "a"
    refute nroot.include? "b"

    assert nnext.include? "b"

    nroot.add_null_node
    nnext.add_null_node

    assert nroot.include? TrieAgain::NullNode
    assert nnext.include? TrieAgain::NullNode
  end

  def test_put_a_word_in_our_trie
    t = TrieAgain.new
    assert t.put "hello"
  end

  def test_find
    t = TrieAgain.new
    t.put "hello"
    assert t.find "hello"
  end

  def test_find_with_a_word_thats_not_there
    t = TrieAgain.new
    t.put "hello"
    refute t.find "hell"
  end

  def test_find_a_smaller_word_if_larger_word_also_present
    t = TrieAgain.new
    t.put "monkey"
    t.put "monk"

    assert t.find("monk")
    assert t.find("monkey")
  end
end
