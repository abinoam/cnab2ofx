module CNAB240Helper

  module StringHelper

    def trim_lzeroes
      self.sub(/^0+/,"")
    rescue ArgumentError => e
      i = self.encode("utf-8", "iso-8859-1") # Brazilian encoding used by some banks
      i.sub(/^0+/,"")
      i.encode("iso-8859-1", "utf-8")
    end

    def date_convert(from, to)
      from_date = DateTime.strptime(self,from) # Import from 'from' DateTime format
      to_date = from_date.strftime(to) # Export to 'to' DateTime format
    end

  end

end
