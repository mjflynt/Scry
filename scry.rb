class Scry < File

    def initialize(*args, **kwargs) #research: anonymous splat does not work here.
        @buff = [nil, nil]
        super(*args, **kwargs)
    end

    def gets(*args, **kwargs)
        while !eof? || !@buff[1].nil?
            if !@buff[0]
                @buff[0] = super(*args, **kwargs)               # no longer needed here... {|line1| @buff[0] = line1 ; break}
            else  
                @buff = @buff.drop(1).push(nil)
            end
            @buff[-1] = super(*args, **kwargs)                  # no longer needed here... {|line2| @buff[1] = line2 ; break}
            return @buff[0]
        end
    end
    
    def each_line(*args, **kwargs)
        while !eof? || !@buff[1].nil?
            if !@buff[0]
                super(*args, **kwargs) {|line| @buff[0] = line ; break} # interception block
            else  
                @buff = @buff.drop(1).push(nil)
            end
            super(*args, **kwargs) {|line| @buff[-1] = line ; break} # interception block
            yield @buff[0] 
        end
    end

    #scry returns the requested @buff rec as a non-destructive look ahead. 
    def scry(buff_ = 1, *args, **kwargs)
        if buff_ < @buff.size
            @buff[buff_] 
        else
            buff_idx = @buff.size
            while buff_idx <= buff_
                @buff.unshift(:gambit)
                @buff[-1] = gets(*args, **kwargs)
                buff_idx += 1
            end
        end
        @buff[buff_]
    end

    #supplant overwrites existing record w/ replacement
    def supplant(buff_, replacement, *args, **kwargs)
        if buff_ < @buff.size
            @buff[buff_] = replacement
        else
            raise ArgumentError
        end
    end

    #inject inserts new_rec before buff_
    def inject(buff_, new_rec, *args, **kwargs)
        if buff_ < @buff.size
            @buff.insert(buff_, new_rec)
        else
            raise ArgumentError
        end
    end

    #excise removes buff_ rec from @buff
    def excise(buff_, *args, **kwargs)
        if buff_ < @buff.size
            @buff.delete_at(buff_)
        else
            raise ArgumentError
        end
    end
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



