require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'line/bot'

get '/' do
    'こんにちは'
end

def client
    @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
end

post '/callback' do
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
        end

        events = client.parse_events_from(body)
        events.each { |event|
            case event
            when Line::Bot::Event::Message
                case event.type
                when Line::Bot::Event::MessageType::Text
                    message = {
                      type: 'text',
                      text: "だからヨハネよッ！"
                    }
                    # message = {
                    #     "type": "template",
                    #     "altText": "Aqours2ndLive",
                    #     "template": {
                    #         "type": "buttons",
                    #         "thumbnailImageUrl": "http://www.lovelive-anime.jp/uranohoshi/img/special/2ndlive/2ndlivelogo.png",
                    #         "title": "Aqours",
                    #         "text": "Please select",
                    #         "actions": [
                    #             {
                    #                 "type": "uri",
                    #                 "label": "詳細を見る",
                    #                 "uri": "http://www.lovelive-anime.jp/uranohoshi/sp_2ndlive.php"
                    #             }
                    #         ]
                    #     }
                    # }
                    # message = {
                    #     "type": "template",
                    #     "altText": "this is a buttons template",
                    #     "template": {
                    #         "type": "buttons",
                    #         "thumbnailImageUrl": "http://www.lovelive-anime.jp/uranohoshi/img/special/2ndlive/2ndlivelogo.png",
                    #         "title": "Aqours2ndLive",
                    #         "text": "Aqours2ndLiveTour決定！",
                    #         "actions": [
                    #             {
                    #                 "type": "uri",
                    #                 "label": "特設サイトはこちら！",
                    #                 "uri": "http://www.lovelive-anime.jp/uranohoshi/sp_2ndlive.php"
                    #             },
                    #             {
                    #                 "type": "uri",
                    #                 "label": "ラブライブ！サンシャインオフィシャルサイトはこちら",
                    #                 "uri": "http://www.lovelive-anime.jp/uranohoshi"
                    #             }
                    #         ]
                    #     }
                    # }

                    client.reply_message(event['replyToken'], message)
                when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
                    response = client.get_message_content(event.message['id'])
                    tf = Tempfile.open("content")
                    tf.write(response.body)
                end
            end
        }
        "OK"
    end
