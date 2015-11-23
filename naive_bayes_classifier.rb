# ナイーブベイズによる文書のカテゴリ推定
class NaiveBayesClassifier
  # 初期化
  def initialize()
    # 出現した単語の集合
    @vocabulary = Set.new
    # カテゴリ毎の単語とその個数
    @word_count = {}
    # カテゴリ毎の記事件数
    @category_count = {}
  end

  # 学習用
  # 単語のカウント
  def count_word(word, category)
    # 存在しなかった場合や無視する単語の場合は処理しない
    return if word[0].nil? || ignore_str?(word[0])
    # 特定の品詞は無視
    return if ignore_pos?(word[1])
    # 原形が存在しない場合は単語をそのまま使う
    if word[2].nil? || word[2] == "<unknown>"
      @word_count[category][word[0]] ||= 0
      @word_count[category][word[0]] += 1
      @vocabulary << word[0]
    else
      @word_count[category][word[2]] ||= 0
      @word_count[category][word[2]] += 1
      @vocabulary << word[2]
    end
  end

  # 学習用
  # カテゴリのカウント
  def count_category(category)
    @category_count[category] ||= 0
    @category_count[category] += 1
  end

  # 学習用
  # 学習を行う
  # words: treetaggerで解析した後のデータ
  # category: 記事のカテゴリ
  def train(words, category)
    @word_count[category] ||= {}
    words.each do |word|
      count_word(word, category)
    end
    count_category(category)
  end

  # 推測用
  # P(category)
  # カテゴリの生起確率
  def prob_category(category)
    @category_count[category].to_f / @category_count.values.sum
  end

  # 推測用
  # ある単語がカテゴリ内に現れた回数
  def count_word_category(word, category)
    return @word_count[category][word] if @word_count[category].key?(word)
    0
  end

  # 推測用
  # P(word, category)
  # 単語wがカテゴリcに現れる確率
  def prob_word_category(word, category)
    alpha = 1.0 # パラメタ
    count = count_word_category(word, category)
    (count + alpha) / (@word_count[category].values.sum + @vocabulary.size * alpha)
  end

  # 推測用
  # P(text, category)
  # カテゴリのときのテキスト(TreeTaggerで解析済み)の確率
  def prob_text_category(words, category)
    score = Math.log(prob_category(category))
    words.each do |word|
      # 不必要なデータは処理しない
      next if word[0].nil? || ignore_str?(word[0])
      # 特定の品詞は無視
      next if ignore_pos?(word[1])
      # 原形が存在しない場合は単語をそのまま使う
      if word[2].nil? || word[2] == "<unknown>"
        score += Math.log(prob_word_category(word[0], category))
      else
        score += Math.log(prob_word_category(word[2], category))
      end
    end
    score
  end

  # 推測用
  # カテゴリ推定
  def classifier(words)
    best = nil
    max = -2147483648
    # カテゴリ毎の確率推定
    @category_count.keys.each do |category|
      prob = prob_text_category(words, category)
      # p category
      # p prob
      if prob > max
        max = prob
        best = category
      end
    end
    best
  end

  # デバッグ用
  def debug
    p "vocabulary size: #{@vocabulary.size}"
    @word_count.keys.each do |category|
      p "vocabulary size(#{category}): #{@word_count[category].values.sum}"
    end
    p @category_count
  end

  # 無視する単語かどうかを判定
  def ignore_str?(word)
    [',', '?', '.', '!', '"', "'", "'s"].include?(word)
  end

  # 無視する品詞かどうか
  def ignore_pos?(pos)
    # return false
    ['DT', 'IN'].include?(pos)
  end
end
