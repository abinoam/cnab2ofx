#!/usr/bin/env ruby
#encoding:utf-8

require 'yaml'
require 'pp'
require 'date'
require 'erb'

CONFIG_DIR = 'config'
VIEW_DIR = 'view' 

class String
  def trim_lzeroes
    self.to_i.to_s
  end

  def date_convert(from, to)
    from_date = DateTime.strptime(self,from) # Import from 'from' DateTime format
    to_date = from_date.strftime(to) # Export to 'to' DateTime format
  end
end

class CNAB240

  attr_reader :cnab240, :dtserver, :org, :fid
  
  def initialize(filename)
    @filename =     filename
    @cnab240 =      parse
    @dtserver =     get_dtserver
    @org = @fid =   get_org
    @bankid =       get_bankid
    @branchid =     get_branchid
    @acctid =       get_acctid
    @balamt =       get_balamt
    @dtasof =       get_dtasof
    @transactions = get_transactions
  end
  
  def to_ofx
    ERB.new(File.read(File.join(VIEW_DIR, "extrato.ofx.erb"))).run(binding)
  end
  
  private
  
  def str_decode_with_headers(str, headers)
    raise ArgumentError, "str.size should be 240 for CNAB240 but it's #{str.size}" if str.size != 240
    str = str.dup
    headers.each_with_object({}) do |(k,v), hsh| 
      hsh[k.to_sym] = str.slice!(0,v) 
    end
  end
  
  def parse

    f = File.open(@filename)
    
    lines = {}

    lines[:header_de_arquivo],
    lines[:header_de_lote],
    *lines[:detalhe_segmento_e],
    lines[:trailer_de_lote],
    lines[:trailer_de_arquivo] = f.readlines
    
    lines.each_with_index.with_object({}) do |((k,v), i), hsh| #|(k,v), i, hsh|
      file_index = "%03d" % i
      fields_headers = YAML.load_file (File.join(CONFIG_DIR, "#{file_index}_registro_#{k}.yaml"))
      case v
      when String
        hsh[k] = str_decode_with_headers(v.chomp, fields_headers)
      when Array
        hsh[k] = v.map {|line| str_decode_with_headers(line.chomp, fields_headers) }
      else
        raise ArgumentError, "v (line) should be Array or String but it is #{v.class} "
      end
    end
  end


  def get_dtserver
    cnab_date_string = @cnab240[:header_de_arquivo][:data_arquivo]+@cnab240[:header_de_arquivo][:hora_arquivo]
    cnab_date_string.date_convert "%d%m%Y%H%M%S", "%Y%m%d%H%M%S"
  end

  def get_org
    @org = @fid = @cnab240[:header_de_arquivo][:nome_banco].strip
  end

  alias get_fid get_org

  def get_bankid
    @cnab240[:header_de_arquivo][:banco].trim_lzeroes
  end

  def get_branchid
    @cnab240[:header_de_arquivo][:agência].trim_lzeroes + "-" +
    @cnab240[:header_de_arquivo][:agência_dv].trim_lzeroes
  end

  def get_acctid
    @cnab240[:header_de_arquivo][:conta_corrente].trim_lzeroes + "-" +
    @cnab240[:header_de_arquivo][:conta_corrente_dv].trim_lzeroes
  end

  def get_balamt
    @cnab240[:trailer_de_lote][:valor_saldo_final].to_f / 100
  end
  
  def get_dtasof
    cnab_date_string = @cnab240[:trailer_de_lote][:data_saldo_final]
    cnab_date_string.date_convert "%d%m%Y", "%Y%m%d"
  end

  def get_transactions
    t = @cnab240[:detalhe_segmento_e].map do |h|
       hash = Hash.new
       hash[:dtposted] = h[:data_lançamento].date_convert("%d%m%Y", "%Y%m%d")
       hash
    end
    puts "Transactions"
    pp t
  end
    
end



filename = ARGV[0] || "UnicredLucas.2013.03.3aVersao.txt"

cnab240 = CNAB240.new(filename)

pp cnab240.cnab240
pp cnab240.dtserver
pp cnab240.fid
pp cnab240.org
pp cnab240.to_ofx

