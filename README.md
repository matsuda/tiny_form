# TinyForm

Rails 3 で該当するモデルの検索フォームを生成するためのモデル  
Fooモデルクラス(app/models/foo.rb)の場合はFooFormクラス(app/forms/foo_form.rb)

## generator

TinyFormのスケルトンファイルを作成

    $ rails g tiny_form Foo
          create  app/forms/foo_form.rb
          invoke  test_unit
          create    test/unit/user_form_test.rb

## attributeの指定

define\_attribute メソッドで 利用したいattributeを指定する。  
ただし、内部的には attr\_accessor を定義しているだけなので、 attr\_accessor でも問題ない。

## 日付カラムの指定

define\_attribute メソッドに :type オプションで日付クラスを指定する。  
現在定義できるのは :date, :datetime, :time の３種類。

## scopedメソッド

該当するモデルクラスのscopeを返す。  
（例）FooFormクラスの場合は、Fooモデルクラスのscopeを返す。  
内部的にはFoo.scopedが実行されている。

## Example

Form

    class FooForm < TinyForm::Base
      define_attribute  :name, :email
      define_attribute  :from_updated_at, :to_updated_at, :type => :datetime

      def scope_search
        scope = scoped
        scope = scope.where(:name => self.name) if self.name.present?
        scope = scope.where(:email => self.email) if self.email.present?
        if self.from_updated_at.present? && self.to_updated_at.present?
          scope = scope.where(:updated_at => self.from_updated_at..self.to_updated_at)
        end
        scope
      end
    end

Controller

    class FooController < ApplicationController
      def index
        @foo_form = FooForm.new(params[:foo_form])
        render :index and return unless @foo_form.valid?
        @foos = @foo_form.scope_search.page(params[:page])
      end
    end

Copyright (c) 2011 Kosuke Matsuda, released under the MIT license
