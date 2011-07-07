require "flac2mp3"
require "test/unit"

class Flac2mp3Test < Test::Unit::TestCase
  
	def setup
    @flac2mp3 = Flac2mp3.new
		Dir.mkdir("test")
	end

	def teardown
 		`rm -rf test`
	end

  def test_recette
    cree_fichier_flac("./test/tmp.flac")
    `lame --silent -V2 --vbr-new -q0 --lowpass 19.7 --resample 44100 ./test/tmp.wav ./test/tmp_attendu.mp3 && eyeD3  -a "artist" -n "1" -A "album" -t "titre" --add-image test/cover.jpg:FRONT_COVER: -G "Electronic" -Y "2008" --set-encoding=utf8 ./test/tmp_attendu.mp3`
    
    @flac2mp3.flac2mp3("./test/tmp.flac","./")
  
    assert_equal(File::Stat.new("./test/tmp_attendu.mp3").size, File::Stat.new("./test/tmp.mp3").size, "la taille des fichiers doit etre la meme")
    mp3tags_attendus = %x[id3tool ./test/tmp_attendu.mp3].gsub(/Filename:.*\n/,"")
    mp3tags_generes = %x[id3tool ./test/tmp.mp3].gsub(/Filename:.*\n/,"")
    assert_equal(mp3tags_attendus,mp3tags_generes, "les tags mp3 doivent etre les memes")
  end
  
  def test_trouve_fichiers_flac
    `mkdir -p test/r1 test/r2/r21 test/r3`
  	`touch test/r1/f11.flac test/r1/f12.flac test/r2/r21/f21.flac`
    liste_attendue = ["./test/r1/f11.flac", "./test/r1/f12.flac", "./test/r2/r21/f21.flac"].sort()
    assert_equal(liste_attendue,  @flac2mp3.trouve_fichiers(".flac", "./").sort())
    assert_equal(liste_attendue,  @flac2mp3.trouve_fichiers(".flac", "./test/r1", "./test/r2").sort())
  end

	def test_convert_arborescence
		`mkdir -p test/r1 test/r2/r21 test/r3`
		cree_fichier_flac("test/r1/f11.flac")
		cree_fichier_flac("test/r1/f12.flac")
		cree_fichier_flac("test/r2/r21/f21.flac")
    begin
      # il faut etre dans le repertoire racine des flacs
      Dir.chdir("test")

      @flac2mp3.trouve_fichiers(".flac", "./").each {|flac| @flac2mp3.flac2mp3(flac, "mp3")}

      assert_equal ["./mp3/r1/f11.mp3", "./mp3/r1/f12.mp3", "./mp3/r2/r21/f21.mp3"].sort, @flac2mp3.trouve_fichiers(".mp3", "./").sort
    ensure Dir.chdir("..")
    end
  end

  def cree_fichier_flac(nom)
    if !File.exist?("./test/tmp.wav")
      donnees_wav=["52","49","46","46","24","08","00","00","57","41","56","45","66","6d","74","20","10","00","00","00","01","00","02","00","22","56","00","00","88","58","01","00","04","00","10","00","64","61","74","61","00","08","00","00","00","00","00","00","24","17","1e","f3","3c","13","3c","14","16","f9","18","f9","34","e7","23","a6","3c","f2","24","f2","11","ce","1a","0d"]
      file = File.new("./test/tmp.wav", "wb")
      donnees_wav.each {|hex| file.putc hex.to_i(16)}
      file.close
    end
    image = File.dirname(nom) + "/cover.jpg"
    `touch #{image}`
    `flac -V --totally-silent -f -T "ARTIST=artist" -T "TRACKNUMBER=1" -T "ALBUM=album" -T "TITLE=titre" -T "GENRE=Electronic" -T "DATE=2008" ./test/tmp.wav -o #{nom}`
  end
end
