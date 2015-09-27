require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'json'
require 'pp'
require "sinatra/json"
require 'sinatra/reloader' if development?

# = ポーカー判定プログラム
# Author::    kohei okuno


##設定：
#YAMLの役設定ロード
configure do
	hand = YAML.load_file('poker_hands.yaml')
	set :hand, hand
end


## 初期表示	
get '/' do
	haml :index, :format => :html5
end

## フォーム入力時の判定
post '/judge' do
	if params['cards']
		 @judgeret = judge(params['cards'])
		 @cards = params['cards']
	end
	haml :index, :format => :html5
end

## API入力時の判定
#==== check
#==== 
#curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"cards":["D2 S2 D2 S9 S9","H2 S2 D2 S9 S10","D8 S5 D4 S10 S1"]}' http://localhost:4567/judgeapi

#{"cards":["D2 S2 D2 S9 S9","H2 S2 D2 S9 S10","D8 S5 D4 S10 S1"]}
#{"cards": [ "H1 H13 H12 H11 H10”, "H9 C9 S9 H2 C2”, "C13 D12 C11 H8 H7” ]}


post '/judgeapi' ,provides: :json do
	params = JSON.parse request.body.read
	ret = []
	if params['cards']
		judges={}
		params['cards'].each{|cards|
			judges.store(cards,judge(cards))
		}
		
		judges.sort_by{|k,j| j['level'].to_i * -1}.each{|k,v|
			cset = {'card'=> k,'hand' =>v['name']}
			cset['best'] = true if ret.count < 1
			ret.push cset
		}
		
	end
	@result = {'result'=>ret}
	json @result
end

## 役の判定処理
def judge(cards)
	if cards.match(/([ ]{0,1}[SHDC]([1][0-3]|[1-9]))\g<1>{4}/)
		crd = cards.scan(/([SHDC])([1][0-3]|[1-9])/)
			.map{|suit,num| [suit,num.to_i]}.sort_by{|suit,num| num.to_i}
		judgehand = nil
		settings.hand.each{|hand|
			judge = false

			if hand['condition'].key?('is_flush')
				judge = _is_flash(crd)
			end
			if hand['condition'].key?('is_straight')
				judge = _is_straight(crd)
			end
			if hand['condition'].key?('count_pair')
				pairjudge = true
				pairs = _count_pair(crd)
				hand['condition']['count_pair'].split(",").each{|v|
					pairset =  pairs.select {|pk, pv| pv == v.to_i }
					if pairset.count > 0 && pairjudge
						pairs.delete(pairset.keys[0])
						pairjudge = true
					else
						pairjudge = false
					end
				}
				judge = pairjudge
			end
			if judge == true
				return hand
			end
		}
		
	end
end

## フラッシュの判定
def _is_flash(cards)
	suit = Hash.new(0)
	["S","H","D","C"].each{|s| suit[s] = cards.flatten.count(s)}
	return suit.value?(5)
end

## ストレートの判定
def _is_straight(cards)
	basenum = cards[0][1]
	for i in 1..4
		if basenum == (cards[i][1] - 1)
			basenum =cards[i][1]
			next
		else
			return false
		end
	end
	pp basenum

	return true
end

## ペア数の判定
def _count_pair(cards)
	pair = Hash.new(0)
	cards.each{|suit,num|
		pair[num] +=1 
	}
	return pair
end

 
