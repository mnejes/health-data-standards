module HealthDataStandards
  module Import
    module CDA
      class ResultImporter < SectionImporter
        def initialize(entry_finder=EntryFinder.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15.1'] | //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']"))
          super(entry_finder)
          @entry_class = LabResult
          @value_xpath = "cda:value | ./cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.87']/cda:value | ./cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.2']/cda:value"
          @result_datetime_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:effectiveTime"
        end
        
        def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
          result = super
          extract_interpretation(entry_element, result)
          extract_reference_range(entry_element, result)
          extract_reason_or_negation(entry_element, result)
          extract_reason_description(entry_element, result, nrh)
          extract_result_date_time(entry_element, result)
          result
        end
    
        private
        def extract_interpretation(parent_element, result)
          interpretation_element = parent_element.at_xpath("./cda:interpretationCode")
          if interpretation_element
            code = interpretation_element['code']
            code_system = CodeSystemHelper.code_system_for(interpretation_element['codeSystem'])
            result.interpretation = {'code' => code, 'codeSystem' => code_system}
          end
        end

        def extract_reference_range(parent_element, result)
          result.reference_range = parent_element.at_xpath("./cda:referenceRange/cda:observationRange/cda:text").try(:text)
        end
    
        def extract_result_date_time(parent_element, result)
          if parent_element.at_xpath("./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:effectiveTime/@value")
            result[:result_date_time] = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:#{element_name}")['value'])
          end
          if parent_element.at_xpath("./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:effectiveTime/cda:low")
            result[:result_date_time] = HL7Helper.timestamp_to_integer(parent_element.at_xpath("cda:#{element_name}/cda:low")['value'])
          end
        end


      end
    end
  end
end
