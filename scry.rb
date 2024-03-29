# mjflynt 20230402

class Scry < File

    def initialize(*args, **kwargs) #research: anonymous splat does not work here.
        scry_init
        super(*args, **kwargs)
    end

    # Antipalaver to hide the ugly boilerplate code "self.class.send( :define_method"
    def def_meth( m, & ) = self.class.send( :define_method, m, & )

    def scry_init

        scrybuff = [nil, nil]   # closure replaces instance variable.

        def_meth :gets do |*args, **kwargs|
            # while !eof? || !scrybuff[1].nil?
            if !eof? || !scrybuff[1].nil?
                if !scrybuff[0]
                    scrybuff[0] = super(*args, **kwargs)               # no longer needed here... {|line1| scrybuff[0] = line1 ; break}
                else  
                    scrybuff = scrybuff.drop(1).push(nil)
                end
                scrybuff[-1] = super(*args, **kwargs)                  # no longer needed here... {|line2| scrybuff[1] = line2 ; break}
                $_ = scrybuff[0]
                # return scrybuff[0]      # <----- do we need the return here? Only one pass thru the loop?
                scrybuff[0]
            end
        end
        
        def_meth :each_line do |*args, **kwargs, &block|
            while !eof? || !scrybuff[1].nil?
                if !scrybuff[0]
                    super(*args, **kwargs) {|line| scrybuff[0] = line ; break} # interception block
                else  
                    scrybuff = scrybuff.drop(1).push(nil)
                    # scrybuff = scrybuff.shift(1).push(nil)  #what is diff with drop and shift?
                end
                super(*args, **kwargs) {|line| scrybuff[-1] = line ; break} # interception block
                $_ = scrybuff[0]
                # yield scrybuff[0]
                block[scrybuff[0]] 
            end
        end
    
        #scry returns the requested scrybuff rec as a non-destructive look ahead. 
        def_meth :scry do |buff_ = 1, *args, **kwargs|
            if buff_ < scrybuff.size
                scrybuff[buff_] 
            else
                buff_idx = scrybuff.size
                while buff_idx <= buff_
                    scrybuff.unshift(:gambit)
                    scrybuff[-1] = gets(*args, **kwargs)
                    buff_idx += 1
                end
            end
            scrybuff[buff_]
        end
    
        #supplant overwrites existing record w/ replacement
        def_meth :supplant do |buff_, replacement|
            if buff_ < scrybuff.size
                scrybuff[buff_] = replacement
            else
                raise ArgumentError
            end
        end
    
        #inject inserts new_rec before buff_
        def_meth :inject do |buff_, new_rec|
            if buff_ < scrybuff.size
                scrybuff.insert(buff_, new_rec)
            else
                raise ArgumentError
            end
        end
    
        #excise removes buff_ rec from scrybuff
        def_meth :excise do |buff_|
            if buff_ < scrybuff.size
                scrybuff.delete_at(buff_)
            else
                raise ArgumentError
            end
        end
    end

    private :scry_init
end


if __FILE__ == $0
    f = nil
    Scry.open("simple.txt", :encoding => 'UTF-8').tap {|o| f = o}.each_line do |ln| 
        print  ln&.chomp
        lookahead = rand(1..10)
        puts " ---> look ahead is #{f.scry&.chomp} and #{lookahead} later is #{f.scry(lookahead)&.chomp}"
        if f.scry(10)&.chomp == 's'
            f.supplant(10, "Jeff was here!")
            f.inject(10, "Jeff was here also!")
        end
    end
    puts '*'*30
    puts f.inspect
end



