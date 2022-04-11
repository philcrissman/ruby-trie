class Dictionary
  attr_reader :store

  def initialize(list)
    # assuming list is a file of newline (\n) separated words 
    # and is case sensitive (ie, Aaron is a word (a name) but aaron isn't)
    words = list_as_words list
    @store = Trie.new
    words.each do |word|
      store.put word
    end
  end

  def find(word)
    store.find(word)
  end

  private
  def list_as_words list
    list.split("\n")
  end
end


class Trie
  TERM = "TERM"

  attr_accessor :root
  
  def initialize
    @root =  {}
  end

  def put word, at=root
    if word.empty?
      at[TERM] = true
    else
      at[word[0]] ||= {}
      put word[1..-1], at[word[0]]
    end
    true
  end

  def find word, at=root
    if at.empty?
      return false
    elsif word.empty?
      at[TERM]
    else
      find word[1..-1], at[word[0]] if word[0]
    end
  end

  def remove word, at=root
    if at.empty?
      return true
    elsif word.empty?
      # delete the TERM const, if its here
      at.delete(TERM)
    else
      remove word[1..-1], at[word[0]]
      if !word[0].empty?
        at.delete(word[0]) if at[word[0]].empty?
      end
    end
  end
end

require 'minitest/autorun'

class TrieTest < Minitest::Test

  def test_root_is_a_hash
    t = Trie.new
    assert t.respond_to? :root
    assert t.root.is_a?(Hash)
  end

  def test_put
    t = Trie.new
    assert t.respond_to? :put
    assert t.put("hello")
  end

  def test_find
    t = Trie.new
    assert t.respond_to? :find
    t.put("hello")
    assert t.find("hello")
  end

  def test_find_knows_a_partial_word_isnt_a_word
    t = Trie.new
    t.put "hello"
    refute t.find("hell")
  end

  def test_find_finds_smaller_words_even_if_larger_exist
    t = Trie.new
    t.put "monkey"
    t.put "monk"

    assert t.find("monk")
  end

  def test_find_finds_larger_words_even_if_smaller_words_exist
    t = Trie.new
    t.put "monkey"
    t.put "monk"

    assert t.find("monkey")
  end

  def test_remove
    t = Trie.new
    assert t.respond_to? :remove
  end

  def test_remove_actually_removes
    t = Trie.new
    t.put "flarble"
    assert t.remove "flarble"
    refute t.find "flarble"
  end

  def test_removing_a_word_that_isnt_there
    t = Trie.new
    # should just... be idempotent? That is, if it isn't there, it does nothing?
    assert t.remove "hello"
  end

  def test_that_using_TERM_is_fine
    t = Trie.new
    t.put "TERM"
    assert t.find("TERM")
    assert t.remove("TERM")
  end
end
