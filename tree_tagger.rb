# 英語の形態素解析(TreeTaggerを使用)
class TreeTagger
  # 与えられたテキストをTreeTaggerで解析し結果を配列として返却
  def self.analysis(text)
    p text
    result = `echo "#{text}" | tree-tagger-english`
    result.split(/\t|\n/).each_slice(3).to_a
  end

  # 名詞に分類されるタグのリスト
  def self.noun_pos_list
    ['NP', 'NN', 'NPS', 'NN N', 'NNS']
  end

  # 形容詞に分類されるタグのリスト
  def self.adj_pos_list
    ['JJ', 'JJR', 'JJS']
  end

  # 動詞に分類されるタグのリスト
  def self.verb_pos_list
    ['VB', 'VBD', 'VBG', 'VBN', 'VBP', 'VBZ']
  end

  # 指定された品詞が大きい分類で何に分類されるかを返却
  def self.judge_pos(pos)
    return "noun" if noun_pos_list.include?(pos)
    return "adj" if adj_pos_list.include?(pos)
    return "verb" if verb_pos_list.include?(pos)
    ""
  end

end
