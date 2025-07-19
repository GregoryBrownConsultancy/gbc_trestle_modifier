# GbcTrestleModifier

## Introduction
[Trestle](https://trestle.io/) is a great tool for rapid prototyping projects. I use it in loads
of my projects. There are a couple of things that kind of tick me off though;

### Large resource files

Trestle resources tend to become large files in the app/admin folder due to the
way they are written. 
I find it hard to read/maintain them as a big file, so I split them up into smaller files and created a generator to ensure that they always follow a standard. 

### Complex menu administration

Another pet peeve is the menu handling. Handling menu itmes in each resource quickly becomes a nightmare. Ordering them requires a lot of manual work. 

To keep things simpler, inspired by the work from the crowd at [WinterCMS](wintercms.com),
I created a `menu.yml` file that is used to manage the menu. I also created a helper that
simplifies the placing of the menu. 

## Splitting up Resources

TODO: Fill this out

## Easy menu administration

TODO: Fill this out

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gbc_trestle_modifier.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
