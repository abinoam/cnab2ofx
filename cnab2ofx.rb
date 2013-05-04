#!/usr/bin/env ruby
#encoding:utf-8

require 'yaml'
require 'pp'
require 'date'
require 'erb'
require './helpers/cnab240_helper.rb' 

CONFIG_DIR = 'config'
VIEW_DIR   = 'view' 

#TODO: Solve the encoding problem

class String
  include CNAB240Helper::StringHelper
end

class CNAB240

  attr_reader :cnab240, :dtserver, :dtstart, :dtend,
              :org, :fid, :bankid, :branchid, :acctid,
              :balamt, :dtasof, :transactions
  
  def initialize(filename)
    @filename =     filename
    @cnab240 =      parse
    @dtserver =     get_dtserver
    @dtstart =      get_dtstart
    @dtend =        get_dtend
    @org = @fid =   get_org
    @bankid =       get_bankid
    @branchid =     get_branchid
    @acctid =       get_acctid
    @balamt =       get_balamt
    @dtasof =       get_dtasof
    @transactions = get_transactions
  end
  
  def to_ofx
    ERB.new(File.read(File.join(VIEW_DIR, "extrato.ofx.erb"))).result(binding)
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

  def get_dtstart
    cnab_date_string = @cnab240[:header_de_lote][:data_saldo_inicial]
    cnab_date_string.date_convert "%d%m%Y", "%Y%m%d"
  end

  def get_dtend
    cnab_date_string = @cnab240[:trailer_de_lote][:data_saldo_final]
    cnab_date_string.date_convert "%d%m%Y", "%Y%m%d"
  end

  alias get_dtasof get_dtend

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

  def get_transactions
    t = @cnab240[:detalhe_segmento_e].map do |t|
       hash = Hash.new
       hash[:dtposted] = t[:data_lançamento].date_convert("%d%m%Y", "%Y%m%d")
       hash[:trnamt] = (t[:valor_lançamento].to_f / 100).to_s
       if t[:tipo_lançamento] == "D"   # (D)ebit = Débito
         hash[:trnamt] = "-"+hash[:trnamt]
       end
       hash[:checknum] = checknum(t)
       hash[:fitid] = "20" + hash[:checknum]
       hash[:memo] = t[:desc_histórico].strip.trim_lzeroes + " - " + t[:num_documento].strip.trim_lzeroes
       hash
    end
  end

  def checknum(t)
    t[:data_lançamento].date_convert("%d%m%Y", "%y%m%d") + #31122013 -> 131231
    t[:valor_lançamento][-8,8] +
    (t[:desc_histórico]+t[:num_documento]).unpack("C*").reduce(:+).to_s
  end
end

filename = ARGV[0] 

raise "Forneça o caminho para um arquivo CNAB240" if ARGV[0].nil?

cnab240 = CNAB240.new(filename)

puts cnab240.to_ofx

#pp cnab240.cnab240
