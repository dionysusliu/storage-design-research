    linux-fsdevel.vger.kernel.org archive mirror
     help / color / mirror / Atom feed

    [PATCH v2] erofs: accept source file descriptor via fsconfig
     2026-07-11  7:10 UTC 

    [PATCH v2 00/33] mm: make VMA page offset handling more consistent
     2026-07-11  6:29 UTC  (44+ messages)
    ` [PATCH v2 01/33] mm: move vma_start_pgoff() into mm.h and clean up
    ` [PATCH v2 02/33] mm: add kdoc comments for vma_start/last_pgoff()
    ` [PATCH v2 03/33] tools/testing/vma: use vma_start_pgoff() in merge tests
    ` [PATCH v2 04/33] mm: introduce and use vma_end_pgoff()
    ` [PATCH v2 05/33] mm/rmap: update mm/interval_tree.c comments
    ` [PATCH v2 06/33] mm/rmap: parameterise vma_interval_tree_*() by address_space
    ` [PATCH v2 07/33] mm/rmap: elide unnecessary static inline's in interval_tree.c
    ` [PATCH v2 08/33] mm/rmap: rename vma_interval_tree_*() to mapping_rmap_tree_*()
    ` [PATCH v2 09/33] mm/rmap: parameterise anon_vma_interval_tree_*() by anon_vma
    ` [PATCH v2 10/33] mm/rmap: rename anon_vma_interval_tree_*() params and use pgoff_t
    ` [PATCH v2 11/33] mm/rmap: rename anon_vma_interval_tree_*() to anon_rmap_tree_*()
    ` [PATCH v2 12/33] MAINTAINERS: Move mm/interval_tree.c to rmap section
    ` [PATCH v2 13/33] mm/vma: introduce and use vmg_pages(), vmg_[start, end]_pgoff()
    ` [PATCH v2 14/33] mm/vma: clean up anon_vma_compatible()
    ` [PATCH v2 15/33] mm/vma: refactor vmg_adjust_set_range() for clarity
    ` [PATCH v2 16/33] mm/vma: minor cleanup of expand_[upwards, downwards]()
    ` [PATCH v2 17/33] mm: introduce and use linear_page_delta()
    ` [PATCH v2 18/33] mm/vma: use vma_start_pgoff(), linear_page_index() in mm code
    ` [PATCH v2 19/33] mm: prefer vma_[start,end]_pgoff() to vma->vm_pgoff in kernel/
    ` [PATCH v2 20/33] mm/vma: remove duplicative vma_pgoff_offset() helper
    ` [PATCH v2 21/33] mm: use linear_page_[index, delta]() consistently
    ` [PATCH v2 22/33] mm/vma: introduce vma_assert_can_modify()
    ` [PATCH v2 23/33] mm/vma: add and use vma_[add/sub]_pgoff()
    ` [PATCH v2 24/33] mm/vma: move __install_special_mapping() to vma.c
    ` [PATCH v2 25/33] mm/vma: make vma_set_range() static, drop insert_vm_struct() decl
    ` [PATCH v2 26/33] mm/vma: update vma_shrink() to not pass start, pgoff parameters
    ` [PATCH v2 27/33] mm/vma: update vmg_adjust_set_range() to offset pgoff instead
    ` [PATCH v2 28/33] mm/vma: slightly rework the anonymous check in __mmap_new_vma()
    ` [PATCH v2 29/33] mm/vma: introduce and use vma_set_pgoff()
    ` [PATCH v2 30/33] mm/vma: correct incorrect vma.h inclusion
    ` [PATCH v2 31/33] mm/vma: use guard clauses in can_vma_merge_[before, after]()
    ` [PATCH v2 32/33] tools/testing/vma: default VMA, mm flag bits to 64-bit
    ` [PATCH v2 33/33] tools/testing/vma: output compared expression on ASSERT_[EQ, NE]()

    [PATCH 00/30] mm: make VMA page offset handling more consistent
     2026-07-11  6:26 UTC  (52+ messages)
    ` [PATCH 02/30] mm: add kdoc comments for vma_start/last_pgoff()
    ` [PATCH 06/30] mm/rmap: parameterise vma_interval_tree_*() by address_space
    ` [PATCH 13/30] mm/vma: refactor vmg_adjust_set_range() for clarity
    ` [PATCH 16/30] mm/vma: use vma_start_pgoff(), linear_page_index() in mm code
    ` [PATCH 17/30] mm: prefer vma_[start,end]_pgoff() to vma->vm_pgoff in kernel/
    ` [PATCH 19/30] mm: use linear_page_[index, delta]() consistently
    ` [PATCH 20/30] mm/vma: introduce vma_assert_can_modify()
    ` [PATCH 21/30] mm/vma: add and use vma_[add/sub]_pgoff()
    ` [PATCH 22/30] mm/vma: move __install_special_mapping() to vma.c
    ` [PATCH 23/30] mm/vma: make vma_set_range() static, drop insert_vm_struct() decl
    ` [PATCH 24/30] mm/vma: update vma_shrink() to not pass unnecessary pgoff parameter
    ` [PATCH 25/30] mm/vma: update vmg_adjust_set_range() to offset pgoff instead
    ` [PATCH 26/30] mm/vma: introduce and use vma_set_pgoff()
    ` [PATCH 27/30] mm/vma: correct incorrect vma.h inclusion
    ` [PATCH 28/30] mm/vma: use guard clauses in can_vma_merge_[before, after]()
    ` [PATCH 29/30] tools/testing/vma: default VMA flag bits to 64-bit
    ` [PATCH 30/30] tools/testing/vma: output compared expression on ASSERT_[EQ, NE]()

    [f2fs-dev] [PATCHv2 0/5] direct-io file extended attributes
     2026-07-11  1:06 UTC  (4+ messages)
        `  "

    [PATCH v6 0/2] Avoid synchronize_rcu() for every thread drop in Rust Binder
     2026-07-11  0:30 UTC  (5+ messages)
    ` [PATCH v6 1/2] rust: poll: use kfree_rcu() for PollCondVar
    ` [PATCH v6 2/2] rust_binder: move (e)poll wait queue to Process

    [PATCH] mm: remove wb_writeout_inc
     2026-07-11  0:11 UTC  (5+ messages)

    [PATCH v11 00/20] fs-verity support for XFS with post EOF merkle tree
     2026-07-10 23:46 UTC  (23+ messages)
    ` [PATCH v11 01/20] fsverity: report validation errors through fserror to fsnotify
    ` [PATCH v11 02/20] fsverity: expose ensure_fsverity_info()
    ` [PATCH v11 03/20] fsverity: pass digest size and hash of the all-zeroes block to ->write
    ` [PATCH v11 04/20] fsverity: hoist pagecache_read from f2fs/ext4 to fsverity
    ` [PATCH v11 05/20] fsverity: improve flushing performance of fsverity_fill_zerohash
    ` [PATCH v11 06/20] fsverity: don't allow setting DAX file attribute on fsverity files
    ` [PATCH v11 07/20] xfs: introduce fsverity on-disk changes
    ` [PATCH v11 08/20] xfs: initialize fs-verity on file open
    ` [PATCH v11 09/20] xfs: don't allow to enable DAX on fs-verity sealed inode
    ` [PATCH v11 10/20] xfs: don't report dio_mem_align and dio_offset_align for fsverity files
    ` [PATCH v11 11/20] xfs: disable direct read path for fs-verity files
    ` [PATCH v11 12/20] xfs: handle fsverity I/O in write/read path
    ` [PATCH v11 13/20] xfs: use read ioend for fsverity data verification
    ` [PATCH v11 14/20] xfs: add fs-verity support
    ` [PATCH v11 15/20] xfs: remove unwritten extents after preallocations in fsverity metadata
    ` [PATCH v11 16/20] xfs: add fs-verity ioctls
    ` [PATCH v11 17/20] xfs: advertise fs-verity being available on filesystem
    ` [PATCH v11 18/20] xfs: check and repair the verity inode flag state
    ` [PATCH v11 19/20] xfs: introduce health state for corrupted fsverity metadata
    ` [PATCH v11 20/20] xfs: enable ro-compat fs-verity flag

    [PATCH] mm: truncate: exit on empty batches in truncate_folio_batch_exceptionals()
     2026-07-10 23:43 UTC  (2+ messages)

    [PATCH] fs: report direct io constraints through file_getattr
     2026-07-10 23:11 UTC  (10+ messages)
        ` [f2fs-dev] "

    [PATCH v2 00/10] Use generic_file_read_iter() in hugetlbfs
     2026-07-10 23:04 UTC  (3+ messages)
    ` [syzbot ci] "

    [PATCH printk 0/3] Introduce sync mode
     2026-07-10 21:05 UTC  (3+ messages)
    ` [PATCH printk 2/3] proc: Add console sync support for /proc/consoles

    [PATCH v2 1/9] security: add LSM blob and hooks for namespaces
     2026-07-10 20:42 UTC  (6+ messages)

    [syzbot] Monthly fs report (Jul 2026)
     2026-07-10 20:32 UTC 

    Should we consider disable generic/563 for file systems that do not support cgroup2?
     2026-07-10 19:10 UTC 

    [PATCH v3 00/14] vfs: add O_CREAT|O_DIRECTORY to open*(2)
     2026-07-10 18:55 UTC  (4+ messages)
    ` [PATCH v3 09/14] "

    [PATCH] ovl: add ioctls to retrieve layer file descriptors
     2026-07-10 18:23 UTC  (10+ messages)

    [PATCH v3] mm/page_alloc: avoid direct compaction for costly __GFP_NORETRY allocations
     2026-07-10 18:03 UTC  (3+ messages)

    [PATCH v4 00/23] ext4: use iomap for regular file's buffered I/O path
     2026-07-10 17:29 UTC  (11+ messages)
    ` [PATCH v4 18/23] ext4: wait for ordered I/O in the iomap "

    [PATCH v2 06/10] memory-failure: Prevent UAF in raw_hwp_page list
     2026-07-10 17:16 UTC  (3+ messages)

    removing the remaining blockdev_direct_IO users
     2026-07-10 16:51 UTC  (2+ messages)

    [PATCH 0/3] vfs: call audit_inode_child() in lookup_open() on failure
     2026-07-10 16:42 UTC  (4+ messages)
    ` [PATCH 1/3] vfs: move create error && negative dentry case in lookup_open() up
    ` [PATCH 2/3] vfs: call audit_inode_child() in lookup_open() on failure
    ` [PATCH 3/3] fs/namei.c: update kerneldoc of atomic_open()

    [PATCH v2 05/10] memory-failure: Remove raw_hwp_list_head()
     2026-07-10 14:55 UTC  (2+ messages)

    [PATCH v2 04/10] hugetlb: Set mapping folio order
     2026-07-10 14:49 UTC  (2+ messages)

    [PATCH v2 03/10] filemap: Remove checks in mapping_set_folio_order_range()
     2026-07-10 14:42 UTC  (2+ messages)

    [PATCH v2 02/10] hugetlb: Mark some function arguments as const
     2026-07-10 14:28 UTC  (2+ messages)

    [PATCH v2 01/10] mm: Rename folio_contain_hwpoison_page() to folio_has_hwpoison_page()
     2026-07-10 14:27 UTC  (2+ messages)

    [PATCH] ext4: fix use-after-free in ext4 delayed I/O completion
     2026-07-10 14:06 UTC  (4+ messages)
    ` [syzbot ci] "

    [PATCH] fs: stat: Mark accesses in generic_fillattr
     2026-07-10 14:05 UTC  (2+ messages)

    [PATCH 0/2] Bring includes in linux/kmod.h up to date
     2026-07-10 13:57 UTC  (3+ messages)
    ` [PATCH 2/2] module: "

    [PATCH vfs/vfs-7.2.xattr v3] bpf: Add simple xattr support to bpffs
     2026-07-10 12:17 UTC  (4+ messages)

    [PATCH] fs/ntfs3: reject an oversized resident attribute on the inline iomap path
     2026-07-10 11:40 UTC  (2+ messages)

    [PATCH 0/2] fs: stable_page_flags(): use folio_test_*() helpers
     2026-07-10 11:29 UTC  (4+ messages)
    ` [PATCH 2/2] "

    [PATCH v2 00/23] binfmt_misc: write access fixes, RCU handler lookup and cleanups
     2026-07-10 10:53 UTC  (7+ messages)
    ` [PATCH v2 04/23] binfmt_misc: use RCU for the handler lookup
    ` [PATCH v2 21/23] binfmt_misc: assorted small cleanups
    ` [PATCH v2 22/23] binfmt_misc: include what is used
    ` [PATCH v2 23/23] binfmt_misc: allow removing entries via unlink(2)

    [PATCH v4] fs/pipe: unify the page pools into a single per-pipe pool
     2026-07-10 10:31 UTC 

    [PATCH v3 00/24] binfmt_misc: write access fixes, RCU handler lookup and cleanups
     2026-07-10  9:33 UTC  (25+ messages)
    ` [PATCH v3 01/24] binfmt_misc: restore write access when removing an entry
    ` [PATCH v3 02/24] binfmt_misc: use exe_file_deny_write_access() for the interpreter clone
    ` [PATCH v3 03/24] binfmt_misc: reject a flag character as the field delimiter
    ` [PATCH v3 04/24] binfmt_misc: convert entry list to an hlist
    ` [PATCH v3 05/24] binfmt_misc: use RCU for the handler lookup
    ` [PATCH v3 06/24] binfmt_misc: annotate racy accesses to ->enabled
    ` [PATCH v3 07/24] binfmt_misc: turn the entry bit numbers into a proper enum
    ` [PATCH v3 08/24] binfmt_misc: turn the entry behavior flags into an enum
    ` [PATCH v3 09/24] binfmt_misc: rename Node to struct binfmt_misc_entry
    ` [PATCH v3 10/24] binfmt_misc: remove the VERBOSE_STATUS toggle
    ` [PATCH v3 11/24] binfmt_misc: use print_hex_dump_debug() for the register debug output
    ` [PATCH v3 12/24] binfmt_misc: convert the entry file to seq_file
    ` [PATCH v3 13/24] binfmt_misc: factor out the entry matching
    ` [PATCH v3 14/24] binfmt_misc: rename load_binfmt_misc() to current_binfmt_misc()
    ` [PATCH v3 15/24] binfmt_misc: return errors directly in load_misc_binary()
    ` [PATCH v3 16/24] binfmt_misc: give the parse_command() results names
    ` [PATCH v3 17/24] binfmt_misc: factor out the entry removal
    ` [PATCH v3 18/24] binfmt_misc: simplify check_special_flags()
    ` [PATCH v3 19/24] binfmt_misc: use a flexible array member for the register string
    ` [PATCH v3 20/24] binfmt_misc: split the field parsing out of create_entry()
    ` [PATCH v3 21/24] binfmt_misc: use __free(kfree) in bm_register_write()
    ` [PATCH v3 22/24] binfmt_misc: assorted small cleanups
    ` [PATCH v3 23/24] binfmt_misc: include what is used
    ` [PATCH v3 24/24] binfmt_misc: allow removing entries via unlink(2)

    [PATCH v3] fs/pipe: unify the page pools into a single per-pipe pool
     2026-07-10  8:37 UTC  (3+ messages)

    [linus:master] [exfat] 82a81a7352: invoked_oom-killer:gfp_mask=0x
     2026-07-10  8:27 UTC 

    [PATCH v2] audit: add FSOPEN record to log filesystem name
     2026-07-10  8:05 UTC  (4+ messages)

    [PATCH] exportfs: fix error handling in expfs.c
     2026-07-10  7:51 UTC  (2+ messages)

    [PATCH v19 00/40] DEPT(DEPendency Tracker)
     2026-07-10  5:53 UTC  (4+ messages)
    ` [PATCH v19 31/40] dept: assign unique dept_key to each distinct wait_for_completion() caller

    [PATCH v2 0/6] Remove __folio_index again
     2026-07-10  5:43 UTC  (6+ messages)
    ` [PATCH v2 2/6] ntfs: Remove use of __folio_index in handle_bounds_compressed_page()

    [PATCH 0/2] Support overlayfs in the idmapped mount tests
     2026-07-10  5:34 UTC  (7+ messages)
    ` [PATCH 1/2] src/vfs: probe O_TMPFILE support on the base mount in the idmapped tests
    ` [PATCH 2/2] src/vfs: skip whiteout-device fixtures on overlayfs

    [PATCH 0/2] fs: refuse O_TMPFILE creation with an unmapped fsuid or fsgid
     2026-07-10  5:31 UTC  (7+ messages)
    ` [PATCH 1/2] "

    [PATCH stable v2] mm/khugepaged: write all dirty file folios when collapsing
     2026-07-10  3:48 UTC  (2+ messages)

    [PATCH v14 0/4] ext4: deferred iput framework for EA inodes
     2026-07-10  3:08 UTC  (5+ messages)
    ` [PATCH v14 1/4] fs: add iput_if_not_last() helper
    ` [PATCH v14 2/4] ext4: introduce ext4_put_ea_inode() for safe deferred iput
    ` [PATCH v14 3/4] ext4: convert all EA inode iput() calls to ext4_put_ea_inode()
    ` [PATCH v14 4/4] ext4: remove ea_inode_array mechanism in favor of ext4_put_ea_inode()

    [PATCH] vboxsf: validate directory entry name length
     2026-07-10  2:31 UTC 

    [PATCH] hfs: don't re-dirty MDB buffers after a write failure
     2026-07-09 22:50 UTC 

------------------------------------------------------------------------

```
page: next (older)
- recent:[subjects (threaded)|topics (new)|topics (active)]
```

------------------------------------------------------------------------

    This is a public inbox, see mirroring instructions
    for how to clone and mirror all data and code used for this inbox;
    as well as URLs for NNTP newsgroup(s).
