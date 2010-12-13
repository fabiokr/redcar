
class ProjectSearch
  class WordSearch
    attr_reader :query_string, :context_size, :project
    
    def initialize(project, query_string, match_case, context_size)
      @project      = project
      @query_string = query_string
      @match_case   = !!match_case
      @context_size = context_size
    end
    
    def match_case?
      @match_case
    end
    
    def matching_line?(line)
      line =~ regex
    end
    
    def regex
      @regex ||= begin
        regexp_text = Regexp.escape(@query_string)
        match_case? ? /#{regexp_text}/ : /#{regexp_text}/i
      end
    end
    
    def results
      []
    end
    
    def bits
      query_string.
        gsub(/[^\w]/, " ").
        gsub("_", " ").
        split(/\s/).
        map {|b| b.strip}.
        reject {|b| b == "" or org.apache.lucene.analysis.standard.StandardAnalyzer::STOP_WORDS_SET.to_a.include?(b)}
    end
    
    def doc_ids
      @doc_ids ||= begin
        index = ProjectSearch.indexes[project.path].lucene_index
        doc_ids = nil
        bits.each do |bit|
          new_doc_ids = index.find(:contents => bit.downcase).map {|doc| doc.id }
          doc_ids = doc_ids ? (doc_ids & new_doc_ids) : new_doc_ids
        end
        doc_ids
      end
    end
  end
end

