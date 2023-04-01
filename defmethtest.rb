class A
    def fred
      puts "In Fred"
    end
    def create_method(name, &block)
      self.class.define_method(name, &block)
    end
    define_method(:wilma) { puts "Charge it!" }
    define_method(:flint) {|name| puts "I'm #{name}!"}
  end
  class B < A
    define_method(:barney, instance_method(:fred))
  end
  a = B.new
  a.barney
  a.wilma
  a.flint('Dino')
  a.create_method(:betty) { p self }
  a.betty
  