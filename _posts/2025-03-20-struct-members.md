# bug snack: Where are my members?

If I declare a struct, where do the members go in memory?

```c=
struct test {
    uint32_t a;
    uint32_t b;
    uint8_t c;
    uint64_t d;
    uint8_t e;
};

int main() {
    struct test t;
    printf("%p\n%p\n%p\n%p\n%p\n", &(t.a), &(t.b), &(t.c), &(t.d), &(t.e));
    return 0;
}
```

Let's check the `sizeof(test)`. There is padding. Explain padding by printing addresses. Now this leads to the real question. If we have padding overhead, why can't the compiler magically solve it.

Does the compiler automatically reorder struct members to be more optimal?

<< https://claude.ai/chat/9b32ddaf-1d13-4e8d-ace5-e7c00c13aa64 >>

If you ask Claude, it says "yes". So it must be true then?

## Quirks about struct initialization

https://stackoverflow.com/questions/12222417/why-should-i-initialize-member-variables-in-the-order-theyre-declared-in

Even if you do things in a different order, the compiler will reorder reads/writes as it wants. Usually it moves these to the start of a function.

So the reason for this is compatibility, right? Now all our programs that define struct members in the same order can happily communicate. 
<< picture of packed memory layout >>

Now that we know the shtick, let's check our mental model with the real world. Let's write a test program to print out the addresses of each of the fields.

<< leetcode stdout >>

Hol' up. This doesn't match what we said. The answer is padding.

Padding makes memory accesses faster.

<< see godbolt >>
If we have a packed struct, we have to access, mask, and write the entire word size to change even one bit. Padding removes this problem.

<< quote code block example. If we have 1 bit field then 32 bit. The 32 bit will spill over and require two memory accesses to use. This is actually what happens when you use things like BigNum to store data wider than the word size of your machine >>
<< nice better example https://stackoverflow.com/a/381368 >>

Great! We are padding by 32 bits since the word size on my machine is 32 bits. Thus, the compiler can write without this extra overhead on each read and write to our struct.

<< aside: I like this explanation for the human reasoning for why the designers would have made this design decision https://stackoverflow.com/a/9491041 >>

<< x86-64 >>

But my machine has 64 bit words?
What gives? If the reason is the overhead of memory accesses, shouldn't the alignment be 64 bits?

<< https://claude.ai/chat/1a99044f-e169-48d7-a1c2-4d2536a5c396 >>

On Intel x86-64, there are different opcodes for differently sized stores and loads. You can call `mov` with different size modifiers like DWORD and QWORD. In arm, there are 32 and 64 bit registers which make stores and load work differently.

The word "word" is misleading in modern machines. For x86, a "word" is still 32 bits on a 64 bit machine. We have instructions that let you do memory operations at 32 and 64 bit. This means that 32 and 64 bit memory operations should have the exact same performance characteristics.

<< https://stackoverflow.com/a/55430777 >>

# So What?

C's reign is falling. In Rust, you do not deal with raw pointer values. The compiler is free to reorder struct members as it wills. In fact, it can even completely change the representation of a type in memory. 
** insert leon/rust book FFI example **
niche optimization https://jpfennell.com/posts/enum-type-size/


# Another wrinkle

It seems quite unfortunate to leave such an obvious optimization on the table. Struct reordering should be transparent to the programmer and supported by the language. Anyways, the compiler knows everything about our program, so it can change how we access the struct. Or does it? It doesn't actually. The exact struct representation matters wheren we are using libraries of things that have not been compiled alongside our program. We cannot change these libraries that we are linking with, so their structs *must* not be changed. Otherwise, you will induce incorrect behavior as the library is expecting to receive the data in a different representation. Another case where this is important is where our programs interact with hardware. Memory registers are sensitive to the exact order of bits. You can imagine that padding will cause the compiler to write to some other random address. There are also structs which are defined by the hardware, such as page table entries (PTEs) and networking packets. These fields are packed and defined by how the hardware represents these fields, which cannot be changed (* usually, link voelker slides. I think there is a such thing as software managed TLB, so the representation and caching policy is flexible). While your compiler can change how all you code uses the struct, your compiler cannot modify your hardware to store network packets more optimally for your program's runtime.

Sure programs *might* have to use external libraries, but I could also statically link my dependencies and compile from scratch. What then? Well `gcc` actually removed support for struct reordering.

But can you think of another place where you have all the code in one place? Which is to say, is there a widely used monolithic codebase we can look at? Linux.

https://stackoverflow.com/questions/30468393/is-it-true-that-tagged-initialization-allows-the-reordering-of-structure-members

Everything I said is a lie. There are many C compilers that can do whatever they want. Most compilers you will come across are spec compliant. However, there are big asterisks to this. For example, the Linux kernel uses unordered structs to enable better cache line optimizations. 

## Looking forward

Most developers still remain surprised that C is the only language to have buffer overflows is a skill issue and impossible to solve. Meanwhile, the world keeps moving forward. Rust's compiler maintains control over the exact representation of data in memory. See the cool optimization for (can't find exact link, Leon will have it for enum niche optimization https://www.0xatticus.com/posts/understanding_rust_niche/). We will see more cool "zero cost" compiler optimizations. Also types can help this situation a lot. Why do I need to keep track of physical addresses of bits while I'm programming? Show a snippet of tock-registers. Also the PMP setup forces you to only write valid PMP configurations. In the type system! And you can even throw in formal methods to force every valid configuration to also be *correct*.

The packed-ness of structs is another knob to tune in program performance. I don't think anyone has tested the tradeoff of modern mega-multi-core CPUs incurring more memory accesses with aligned structs vs more CPU operations but more cache hits with packed structs.
Another funny wrinkle is that we aren't actually allocating the exact memory. You are probably using a slab allocator on the heap to minimize fragmentation overhead. The slab allocator is allocating based on a fixed size greater than, and probably not equal to, the size of the struct. So these optimizations may anyways be relevant. *memory is cheap* as they say. (Rust rounds allocations up to the nearest alignment https://doc.rust-lang.org/std/alloc/struct.Layout.html)

We cannot draw any strong conclusions from this post. However, there are thousands of similar things we take for granted that are changing. I think we need to critically look at how we co-design programming languages, software, and hardware for this new generation of computing (* for example, look at CHERI, which spans all these three and is a very interesting future of computing).

As soon as your software touches the real world, everything becomes unimaginably complex. All software engineers need to touch ~~grass~~ hardware to see what goes on.

I'll leave you with one closing thought. The next time you are ordering the items in a struct, remember you are not just a "programmer". See yourself as a wanderer traveling through the space-time continuum.

https://www.reddit.com/r/cpp_questions/comments/17okhcr/does_ordering_of_struct_members_matter_for_memory/
https://stackoverflow.com/a/38248715 very nice post. C++ does allow reordering of members of different access types (https://en.cppreference.com/w/cpp/language/data_members#Standard_layout)
https://en.wikipedia.org/wiki/Data_structure_alignment
http://www.catb.org/esr/structure-packing/#_who_should_read_this TODO: read this.

So what is my conclusion? I do not believe that there is any fundamental technical reason that code doesn't support reordering structs, even in the case where you have legacy software. As with all problems, you can solve them with another layer of indirection. If you have many independent pieces of software which want to communicate objects, you can use an abstraction layer like protobufs. I also have realized the reason this doesn't exist is because you must both create the software and then convince the world of its utility. Look at how LLVM added C bounds checking. See the section "Overhead of bounds checking: I was wrong" of https://chandlerc.blog/posts/2024/11/story-time-bounds-checking/.
