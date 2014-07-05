# encoding: utf-8

require 'spec_helper'
require 'ruby_speech'

module Adhearsion
  class CallController
    describe Utility do
      include CallControllerTestHelpers

      describe "#grammar_digits" do
        let(:grxml) {
          RubySpeech::GRXML.draw :mode => 'dtmf', :root => 'inputdigits' do
            rule id: 'inputdigits', scope: 'public' do
              item repeat: '2' do
                one_of do
                  0.upto(9) { |d| item { d.to_s } }
                end
              end
            end
          end
        }

        it 'generates the correct GRXML grammar' do
          expect(subject.grammar_digits(2).to_s).to eq(grxml.to_s)
        end

      end # describe #grammar_digits

      describe "#grammar_accept" do
        let(:grxml) {
          RubySpeech::GRXML.draw :mode => 'dtmf', :root => 'inputdigits' do
            rule id: 'inputdigits', scope: 'public' do
              one_of do
                item { '3' }
                item { '5' }
              end
            end
          end
        }

        it 'generates the correct GRXML grammar' do
          expect(subject.grammar_accept('35').to_s).to eq(grxml.to_s)
        end

        it 'filters meaningless characters out' do
          expect(subject.grammar_accept('3+5').to_s).to eq(grxml.to_s)
        end
      end # grammar_accept

      describe "#parse_dtmf" do
        context "with a single digit" do
          it "correctly returns the parsed input" do
            expect(subject.parse_dtmf("dtmf-3")).to eq('3')
          end

          it "correctly returns star as *" do
            expect(subject.parse_dtmf("dtmf-star")).to eq('*')
          end

          it "correctly returns * as *" do
            expect(subject.parse_dtmf("*")).to eq('*')
          end

          it "correctly returns pound as #" do
            expect(subject.parse_dtmf("dtmf-pound")).to eq('#')
          end

          it "correctly returns # as #" do
            expect(subject.parse_dtmf("#")).to eq('#')
          end

          it "correctly parses digits without the dtmf- prefix" do
            expect(subject.parse_dtmf('1')).to eq('1')
          end

          it "correctly returns nil when input is nil" do
            expect(subject.parse_dtmf(nil)).to eq(nil)
          end
        end

        context "with multiple digits separated by spaces" do
          it "returns the digits without space separation" do
            expect(subject.parse_dtmf('1 dtmf-5 dtmf-star # 2')).to eq('15*#2')
          end
        end
      end # describe #grammar_accept
    end
  end
end
