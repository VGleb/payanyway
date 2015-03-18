[![Build Status](https://travis-ci.org/ssnikolay/payanyway.svg?branch=master)](https://travis-ci.org/ssnikolay/payanyway)
[![Code Climate](https://codeclimate.com/github/ssnikolay/payanyway.svg)](https://codeclimate.com/github/ssnikolay/payanyway)
[![Test Coverage](https://codeclimate.com/github/ssnikolay/payanyway/badges/coverage.svg)](https://codeclimate.com/github/ssnikolay/payanyway)

# Payanyway

Этот gem предназначен для быстрой интеграции платежного шлюза [payanyway](http://payanyway.ru) в ваше ruby приложение.
При возникновенни вопросов следует ознакомиться с [http://moneta.ru/doc/MONETA.Assistant.ru.pdf](http://moneta.ru/doc/MONETA.Assistant.ru.pdf)
## Установка

Добавьте эти строки в Gemfile вашего приложения:

```ruby
gem 'payanyway'
```

И выполните:

    $ bundle

Или установки напрямую:

    $ gem install payanyway

## Подключение

Добавьте engine в `config/routes.rb`
```ruby
Rails.application.routes.draw do
  mount Payanyway::Engine => '/payanyway'
end
```

Создайте `app/controllers/payanyway_controller.rb` со следующим кодом:

```ruby
class PayanywayController
  def success_implementation(order_id)
    # вызывается при отправки шлюзом пользователя на Success URL.
    #
    # ВНИМАНИЕ: является незащищенным действием!
    # Для выполнения действий после успешной оплаты используйте pay_implementation
  end
  
  def pay_implementation(params)
    # вызывается при оповещении магазина об 
    # успешной оплате пользователем заказа.
    #
    #  params[ KEY ], где KEY ∈ [ :moneta_id, :order_id, :operation_id,
    #  :amount, :currency, :subscriber_id, :test_mode, :user, :corraccount,
    #  :custom1, :custom2, :custom3 ]
  end
  
  def fail_implementation(order_id)
    # вызывается при отправки шлюзом пользователя на Fail URL.
  end
end
```

Создайте конфигурационный файл: `config/payanyway.yml`


```yml
development: &config
    moneta_id: YOUR_MOTETA_ID
    currency: RUB
    payment_url: https://demo.moneta.ru/assistant.htm
    test_mode: 1
    token: secret_token
production: <<: *config
    payment_url: https://moneta.ru/assistant.htm
    test_mode: 0
```
## Использование

Что бы получить ссылку на платежный шлюз для оплаты заказа пользвателем,
используйте `Payanyway::Gateway.payment_url(params, use_signature = true)`,
где `params[ KEY ]` такой, что `KEY` ∈
`[:order_id, :amount, :test_mode, :description, :subscriber_id, :custom1, :custom2, :custom3, :locale, :payment_system_unit_id, :payment_system_limit_ids]`

Если в настройках счета в системе **moneta.ru** выставлен флаг «Можно переопределять настройки в URL», то можно так же передавать 
`[:success_url, :inprogress_url, :fail_url, :return_url]`

Пример:
```ruby
class Order < ActiveRecord::Base; end

class OrdersController < AplicationController
  def create
    order = Order.create(params[:order])
    redirect_to Payanyway::Gateway.payment_url(
      order_id: order.id,
      amount: order.total_amount,
      locale: 'ru',
      description: "Оплата заказа № #{ order.number } на сумму #{ order.total_amount }руб."
    )
  end
end
```

### Расшифровка параметров

 params[ KEY ], где KEY    | Описание
---------------------------|:-----------------------------------------------------------
`:moneta_id`               | Идентификатор магазина в системе MONETA.RU.
`:order_id`                | Внутренний идентификатор заказа, однозначно определяющий заказ в магазине.
`:operation_id`            | Номер операции в системе MONETA.RU.
`:amount`                  | Фактическая сумма, полученная на оплату заказа.
`:currency`                | ISO код валюты, в которой произведена оплата заказа в магазине.
`:test_mode`               | Флаг оплаты в тестовом режиме (1 - да, 0 - нет).
`description`              | Описание оплаты.
`:subscriber_id`           | Внутренний идентификатор пользователя в системе магазина.
`:corraccount`             | Номер счета плательщика.
`:custom[1|2|3]`           | Поля произвольных параметров. Будут возращены
магазину в параметрах отчета о проведенной оплате.
`:user`                    | Номер счета пользователя, если оплата производилась с пользовательского счета в системе «MONETA.RU».MONETA.Assistant.
`:locale`                  | (ru|en) Язык пользовательского интерфейса.
`:payment_system_unit_id`  | Предварительный выбор платежной системы.
(https://www.moneta.ru/viewPaymentMethods.htm)
`:payment_system_limit_ids`| Список (разделенный запятыми) идентификаторов
платежных систем, которые необходимо показывать пользователю.
`:success_url`             | URL страницы магазина, куда должен попасть
покупатель после успешно выполненных действий.
`:inprogress_url`          | URL страницы магазина, куда должен попасть
покупатель после успешного запроса на авторизацию средств, до подтверждения
списания и зачисления средств.
`:fail_url`                | URL страницы магазина, куда должен попасть покупатель после отмененной или неуспешной оплаты.
`:return_url`              | URL страницы магазина, куда должен вернуться
покупатель при добровольном отказе от оплаты.


## Contributing

1. Fork it ( https://github.com/ssnikolay/payanyway/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
