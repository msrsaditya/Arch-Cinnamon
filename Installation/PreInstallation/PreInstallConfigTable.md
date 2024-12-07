| **Category**           | **Setting**                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| **Language**           | English                                                                    |
| **Audio Configuration** | PipeWire                                                                   |
| **Bootloader**         | GRUB                                                                       |
| **Disk Configuration** | **Device:** `/dev/sda`                                                     |
|                         | - **Wipe Disk:** `true`                                                   |
|                         | - **Partition 1:** `/boot` (1 GiB, FAT32, Boot Flag)                      |
|                         |   - **Start:** 3 MiB                                                      |
|                         |   - **Sector Size:** 512 B                                                |
|                         | - **Partition 2:** `/` (50 GiB, EXT4)                                     |
|                         |   - **Start:** 1,076,887,552 B                                            |
|                         |   - **Sector Size:** 512 B                                                |
|                         | - **Partition 3:** `/home` (Remaining space, EXT4)                       |
|                         |   - **Start:** 54,763,978,752 B                                           |
|                         |   - **Sector Size:** 512 B                                                |
| **Disk Encryption**     | None                                                                      |
| **Hostname**           | ArchLinux                                                                 |
| **Kernel**             | Linux                                                                     |
| **Locale Settings**    | **Keyboard Layout:** US                                                   |
|                         | **System Encoding:** UTF-8                                               |
|                         | **System Language:** en_US.UTF-8                                         |
| **Network Configuration**| ISO                                                                      |
| **NTP**                | Enabled (Time Synchronization)                                             |
| **Packages**           | None                                                                      |
| **Parallel Downloads** | 0                                                                         |
| **Profile Configuration** | **Profile Type:** Minimal                                               |
|                         | **Custom Settings:** None                                                |
| **Swap**               | Enabled                                                                   |
| **Timezone**           | UTC                                                                       |
| **UKI (Unified Kernel Image)** | Disabled                                                           |
| **Version**            | 3.0.1                                                                     |
| **User Credentials**   | **Root Password:** `asdf`                                                 |
|                         | **Users:**                                                               |
|                         | - **Username:** `user`                                                   |
|                         |   - **Password:** `asdf`                                                 |
|                         |   - **Sudo Access:** `true`                                              |
