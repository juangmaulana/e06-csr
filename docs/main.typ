    #set enum(numbering: "a)")

= Dokumentasi Tugas PBKK E06 - CSR

#v(0.3cm)

Nama: Juang Maulana Taruna Putra
NRP: 5025231257

#v(0.5cm)

== 1. Backend - Post Service (`posts.service.ts`)

=== a. Create
```ts
  async create(createPostDto: CreatePostDto) {
    return this.prisma.post.create({
      data: createPostDto,
      include: {
        replies: {
          include: {
            replies: true, // Include nested replies
          },
        },
      },
    });
  }
Fungsi create digunakan untuk membuat post baru atau sebuah reply. Fungsi ini menerima createPostDto yang berisi posterName, content, dan replyToId (opsional). Data ini langsung diteruskan ke prisma.post.create. Opsi include digunakan untuk memastikan data post yang dikembalikan menyertakan relasi replies (termasuk replies dari replies itu sendiri secara nested) jika ada, meskipun untuk post baru biasanya belum ada replies.

#line(length: 100%)

=== b. Read (Find All)

  async findAll() {
    return this.prisma.post.findMany({
      include: {
        replies: {
          include: {
            replies: true, // Include nested replies
          },
          orderBy: {
            createdAt: 'asc', // Order replies ascending
          },
        },
      },
      orderBy: {
        createdAt: 'desc', // Order top-level posts descending
      },
    });
  }
Fungsi findAll mengambil semua post dari database. Menggunakan prisma.post.findMany tanpa filter where spesifik, sehingga semua record diambil. Opsi include digunakan untuk mengambil data replies yang berelasi, termasuk nested replies. Replies diurutkan berdasarkan createdAt secara ascending (dari terlama ke terbaru), sedangkan post utama diurutkan secara descending (dari terbaru ke terlama).

#line(length: 100%)

=== c. Read (Find One)

  async findOne(id: string) {
    const post = await this.prisma.post.findUnique({
      where: { id },
      include: {
        replies: {
          include: {
            replies: true, // Include nested replies
          },
          orderBy: {
            createdAt: 'asc', // Order replies ascending
          },
        },
        replyTo: true, // Include the post this one replies to
      },
    });

    if (!post) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    return post;
  }
Fungsi findOne mengambil satu post spesifik berdasarkan id. Menggunakan prisma.post.findUnique dengan klausa where. Opsi include digunakan untuk mengambil replies (beserta nested replies, diurutkan ascending) dan juga post replyTo (post asli yang dibalas oleh post ini). Jika post dengan id tersebut tidak ditemukan, sebuah NotFoundException akan dilempar.

#line(length: 100%)

=== d. Update

  async update(id: string, updatePostDto: UpdatePostDto) {
    const existingPost = await this.prisma.post.findUnique({
      where: { id },
    });

    if (!existingPost) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    return this.prisma.post.update({
      where: { id },
      data: updatePostDto, // updatePostDto contains fields to update
      include: {
        replies: {
          include: {
            replies: true, // Include nested replies
          },
        },
      },
    });
  }
Fungsi update memperbarui data post berdasarkan id. Pertama, fungsi ini memeriksa apakah post dengan id tersebut ada menggunakan findUnique. Jika tidak ada, NotFoundException dilempar. Jika ada, prisma.post.update dipanggil dengan updatePostDto yang berisi field yang akan diubah (posterName dan/atau content). Opsi include disertakan untuk mengembalikan data post yang diperbarui beserta replies-nya.

#line(length: 100%)

=== e. Delete (Remove)

  async remove(id: string) {
    const existingPost = await this.prisma.post.findUnique({
      where: { id },
    });

    if (!existingPost) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    // Prisma handles cascading delete based on schema relation
    return this.prisma.post.delete({
      where: { id },
    });
  }
Fungsi remove menghapus post berdasarkan id. Sama seperti update, fungsi ini pertama memeriksa keberadaan post. Jika tidak ditemukan, NotFoundException dilempar. Jika ditemukan, prisma.post.delete dipanggil. Berdasarkan skema Prisma (onDelete: Cascade pada relasi PostReplies), penghapusan post ini akan secara otomatis menghapus semua post lain yang me-reply post ini (dan seterusnya secara rekursif).

#line(length: 100%)

=== f. Find Replies

  async findReplies(id: string) {
    const post = await this.prisma.post.findUnique({
      where: { id },
    });

    if (!post) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    // Find posts where replyToId matches the given id
    return this.prisma.post.findMany({
      where: { replyToId: id },
      include: {
        replies: {
          include: {
            replies: true, // Include nested replies
          },
        },
      },
      orderBy: {
        createdAt: 'asc', // Order replies ascending
      },
    });
  }
Fungsi findReplies secara spesifik mengambil semua replies langsung dari sebuah post berdasarkan id. Fungsi ini pertama memastikan post induk ada. Jika ada, prisma.post.findMany digunakan dengan filter where: { replyToId: id } untuk mencari semua post yang field replyToId-nya adalah id dari post induk. Hasilnya diurutkan ascending berdasarkan waktu pembuatan dan menyertakan nested replies.

#line(length: 100%)

== 2. Backend - Post Controller (posts.controller.ts)

=== a. Create (POST /posts)

  @Post()
  @HttpCode(HttpStatus.CREATED) // Set HTTP status code to 201
  create(@Body() createPostDto: CreatePostDto) {
    return this.postsService.create(createPostDto);
  }
Method ini menangani request POST ke /posts. Menggunakan decorator @Body untuk mengambil data dari request body dan memvalidasinya sesuai CreatePostDto. Decorator @HttpCode(HttpStatus.CREATED) memastikan response status adalah 201 Created jika berhasil. Method ini memanggil postsService.create untuk menyimpan post baru.

#line(length: 100%)

=== b. Read All (GET /posts)

  @Get()
  findAll() {
    return this.postsService.findAll();
  }
Method ini menangani request GET ke /posts. Tidak memerlukan parameter. Langsung memanggil postsService.findAll untuk mengambil semua post beserta replies-nya dan mengembalikannya sebagai response.

#line(length: 100%)

=== c. Read One (GET /posts/:id)

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.postsService.findOne(id);
  }
Method ini menangani request GET ke /posts/:id, di mana :id adalah path parameter. Menggunakan decorator @Param('id') untuk mengekstrak id dari URL. Memanggil postsService.findOne dengan id tersebut. Jika service melempar NotFoundException, NestJS akan secara otomatis mengubahnya menjadi response 404 Not Found.

#line(length: 100%)

=== d. Update (PUT /posts/:id)

  @Put(':id')
  update(@Param('id') id: string, @Body() updatePostDto: UpdatePostDto) {
    return this.postsService.update(id, updatePostDto);
  }
Method ini menangani request PUT ke /posts/:id. Menggunakan @Param('id') untuk mendapatkan id post yang akan diupdate dan @Body untuk mendapatkan data update (UpdatePostDto). Memanggil postsService.update untuk melakukan pembaruan. Jika post tidak ditemukan, service akan melempar NotFoundException yang menghasilkan response 404.

#line(length: 100%)

=== e. Delete (DELETE /posts/:id)

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT) // Set HTTP status code to 204
  remove(@Param('id') id: string) {
    return this.postsService.remove(id);
  }
Method ini menangani request DELETE ke /posts/:id. Menggunakan @Param('id') untuk mendapatkan id post yang akan dihapus. Decorator @HttpCode(HttpStatus.NO_CONTENT) memastikan response status adalah 204 No Content jika berhasil. Memanggil postsService.remove. Jika post tidak ditemukan, service akan melempar NotFoundException (404).

#line(length: 100%)

=== f. Get Replies (GET /posts/:id/replies)

  @Get(':id/replies')
  findReplies(@Param('id') id: string) {
    return this.postsService.findReplies(id);
  }
Method ini menangani request GET ke /posts/:id/replies. Menggunakan @Param('id') untuk mendapatkan id dari post induk. Memanggil postsService.findReplies untuk mengambil semua replies langsung dari post tersebut. Jika post induk tidak ditemukan, service akan melempar NotFoundException (404).

#line(length: 100%)

== 3. View (Front End - Next.js Pages)

=== a. index.tsx (All Posts Page)

  async function loadPosts() {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/posts`, { /* ... */ });
      if (!response.ok) { /* ... handle error ... */ }
      const data = await response.json();
      setPosts(data);
    } catch (err) { /* ... handle error ... */
    } finally { setLoading(false); }
  }

  useEffect(() => { loadPosts(); }, []);

  async function handleDelete(id: string) {
    if (confirm("Are you sure?")) {
      try {
        const response = await fetch(`${API_BASE_URL}/posts/${id}`, { method: 'DELETE' });
        if (!response.ok) { /* ... handle error ... */ }
        await loadPosts(); // Reload posts after deletion
        alert("Deleted successfully.");
      } catch (err) { /* ... handle error ... */ }
    }
  }
Halaman utama (index.tsx) menggunakan useEffect untuk memanggil loadPosts saat komponen pertama kali dimuat (client-side). Fungsi loadPosts melakukan fetch ke endpoint GET /posts di backend. State loading dan error digunakan untuk menampilkan UI yang sesuai selama proses fetch. Data post yang diterima disimpan dalam state posts dan di-render. Terdapat juga fungsi handleDelete yang mengirim request DELETE ke backend saat tombol delete diklik, lalu memanggil loadPosts lagi untuk memperbarui daftar post.

#line(length: 100%)

=== b. [id].tsx (Post Detail Page)

  useEffect(() => {
    // ... guard for postId ...
    async function loadPost() {
      setLoading(true); setError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/posts/${postId}`);
        // ... handle response (ok, 404, error) ...
        const data = await response.json();
        setPost(data);
        // Fetch the parent post if it's a reply (data.replyToId exists)
        // Note: The backend already includes replyTo data if available
      } catch (err) { /* ... handle error ... */
      } finally { setLoading(false); }
    }
    loadPost();
  }, [postId, router]);

  async function handleDelete() {
    if (confirm("Are you sure ...")) {
      try {
        // ... fetch DELETE /posts/${post?.id} ...
        router.push("/"); // Redirect to home after deletion
      } catch (err) { /* ... handle error ... */ }
    }
  }
Halaman detail post ([id].tsx) mengambil id post dari URL router (router.query). useEffect digunakan untuk memanggil loadPost saat postId berubah. Fungsi loadPost melakukan fetch ke GET /posts/:id. Jika post tidak ditemukan (404), pengguna diarahkan kembali ke halaman utama. Jika berhasil, data post (termasuk replyTo dan replies dari backend) disimpan dalam state post. Fungsi handleDelete mirip dengan di index.tsx, namun setelah berhasil menghapus, pengguna diarahkan kembali ke halaman utama..tsx]

#line(length: 100%)

=== c. new.tsx (Create New Post Page)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // ... validate inputs ...
    setIsSubmitting(true); setError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/posts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          posterName: posterName.trim(),
          content: content.trim(),
        }),
      });
      if (!response.ok) { throw new Error(/* ... */); }
      // ... handle success (alert, redirect) ...
      router.push("/");
    } catch (err) { /* ... handle error ... */
    } finally { setIsSubmitting(false); }
  }
Halaman pembuatan post baru (new.tsx) menggunakan state (posterName, content) untuk mengelola input form. Fungsi handleSubmit dipanggil saat form disubmit. Fungsi ini mengirim request POST ke /posts dengan data dari state. Jika berhasil, pengguna diberi notifikasi dan diarahkan ke halaman utama. State isSubmitting dan error digunakan untuk feedback UI.

#line(length: 100%)

=== d. [id]/reply.tsx (Reply to Post Page)

  useEffect(() => {
    // ... guard for postId ...
    async function fetchPost() { // Fetch the post being replied to
      try {
        const response = await fetch(`${API_BASE_URL}/posts/${postId}`);
        if (response.ok) { setPost(await response.json()); }
        else { router.push("/"); }
      } catch { router.push("/"); }
      finally { setLoading(false); }
    }
    fetchPost();
  }, [postId, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // ... validate inputs ...
    setIsSubmitting(true);
    try {
      const response = await fetch(`${API_BASE_URL}/posts`, {
        method: "POST",
        headers: { /* ... */ },
        body: JSON.stringify({
          posterName: posterName.trim(),
          content: content.trim(),
          replyToId: postId, // Include the ID of the post being replied to
        }),
      });
      if (response.ok) { router.push(`/posts/${postId}`); } // Redirect back to original post
      else { /* ... handle error ... */ }
    } catch { /* ... handle error ... */
    } finally { setIsSubmitting(false); }
  }
Halaman reply ([id]/reply.tsx) pertama-tama mengambil data post asli yang akan direply (fetchPost) untuk ditampilkan sebagai konteks. Form submit (handleSubmit) mirip dengan new.tsx, namun saat mengirim request POST ke /posts, field replyToId diisi dengan postId dari URL, menandakan bahwa post baru ini adalah reply. Setelah berhasil, pengguna diarahkan kembali ke halaman detail post asli./reply.tsx]

#line(length: 100%)

=== e. [id]/edit.tsx (Edit Post Page)

  useEffect(() => {
    // ... guard for postId ...
    async function fetchPost() { // Fetch the post to be edited
      try {
        const response = await fetch(`${API_BASE_URL}/posts/${postId}`);
        if (response.ok) {
          const postData = await response.json();
          setPost(postData);
          setContent(postData.content); // Pre-fill the content textarea
        } else { router.push("/"); }
      } catch { router.push("/"); }
      finally { setLoading(false); }
    }
    fetchPost();
  }, [postId, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // ... validate content ...
    setIsSubmitting(true);
    try {
      const response = await fetch(`${API_BASE_URL}/posts/${postId}`, {
        method: "PUT", // Use PUT for update
        headers: { /* ... */ },
        body: JSON.stringify({ content: content.trim() }), // Only send content for update
      });
      if (response.ok) { router.push(`/posts/${postId}`); } // Redirect back to post detail
      else { /* ... handle error ... */ }
    } catch { /* ... handle error ... */
    } finally { setIsSubmitting(false); }
  }
Halaman edit ([id]/edit.tsx) mengambil data post yang akan diedit (fetchPost) dan mengisi state content dengan data yang ada. Fungsi handleSubmit mengirim request PUT ke /posts/:id dengan field content yang baru. Nama poster tidak bisa diubah di halaman ini. Setelah berhasil update, pengguna diarahkan kembali ke halaman detail post./edit.tsx]

#line(length: 100%)

== 4. Perbandingan Template Engine dan Client Side Rendering (CSR)

Untuk situs web dinamis seperti media sosial, Client-Side Rendering (CSR) seringkali dianggap lebih unggul dibandingkan Template Engine seperti EJS. Kelebihan utama CSR terletak pada kemampuannya menciptakan pengalaman pengguna yang lebih interaktif dan responsif, karena pembaruan tampilan terjadi di sisi klien (browser) tanpa memuat ulang seluruh halaman. Sebaliknya, EJS cenderung menghasilkan halaman yang lebih statis atau kaku.

Namun, dari segi pengembangan, CSR bisa jadi lebih kompleks. Pengembang perlu mengelola logika untuk view, model, dan controller secara terpisah di sisi klien, serta menangani pengambilan data dari API. Di sisi lain, Template Engine seringkali lebih sederhana karena view dirender di server dengan data yang sudah disiapkan, sehingga pengembang lebih fokus pada model dan controller di backend dengan fungsi view yang relatif simpel.

Secara umum, untuk aplikasi modern yang mengutamakan responsivitas dan interaksi pengguna yang kaya, CSR merupakan pilihan yang lebih baik. Sementara itu, Template Engine seperti EJS tetap menjadi pilihan yang solid untuk situs web yang lebih statis, contohnya landing page, di mana interaksi pengguna tidak terlalu intensif.
